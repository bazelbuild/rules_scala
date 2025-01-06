package io.bazel.rules_scala.dottyijar

import com.softwaremill.tagging.*
import java.util.UUID
import io.bazel.rules_scala.dottyijar.tasty.*
import io.bazel.rules_scala.dottyijar.tasty.format.{MarkerType, TastyFormat, TastyReader, TastyReference, TastyWriter, Unsigned}
import scala.collection.mutable

/**
 * This class is the meat of dottyijar. It's responsible for transforming the read TASTy file into the one written by
 * dottyijar. Currently all it does is:
 *   - Clear the TASTy UUID, positions section, and comments section
 *   - Remove all `val` and `def` definitions that are private and not inline
 *   - Replace the values of all `val` and `def` definitions and class parent arguments with `???`
 *   - Remove unused names from the name table
 */
private class ContextualTastyUpdater(oldTasty: Tasty) {
  private var nextNameIndex = oldTasty.nameTable.names.length
  private val addedNames = mutable.ArrayBuffer.empty[TastyName]
  private def getOrCreateNameReference(name: TastyName): TastyNameReference = oldTasty.nameTable.names.zipWithIndex
    .collectFirst { case (`name`, i) => TastyNameReference(i.taggedWith[Unsigned]) }
    .getOrElse(
      TastyNameReference(
        {
          val i = nextNameIndex

          nextNameIndex += 1
          addedNames += name

          i
        }.taggedWith[Unsigned],
      ),
    )

  private lazy val scalaNameReference = getOrCreateNameReference(TastyName.Simple("scala"))
  private lazy val predefNameReference = getOrCreateNameReference(TastyName.Simple("Predef"))
  private lazy val `???nameReference` = getOrCreateNameReference(TastyName.Simple("???"))
  private lazy val `???identifier` = TastyTerm.Identifier(
    `???nameReference`,
    TastyType.NonLocalReference(predefNameReference, TastyType.PackageReference(scalaNameReference)),
  )

  private def updateAstsSection(
    section: TastySection[TastySectionPayload.Asts],
  ): TastySection[TastySectionPayload.Asts] =
    section.copy(payload = updateAstsSectionPayload(section.payload))

  private def updateAstsSectionPayload(payload: TastySectionPayload.Asts): TastySectionPayload.Asts =
    TastySectionPayload.Asts(payload.topLevelStatements.flatMap(updateTopLevelStatement))

  private def updateStatement(statement: TastyStatement): Option[TastyStatement] =
    statement match {
      case _: TastyTerm => None
      case definition: TastyValOrDefDefinition => updateValOrDefDefinition(definition)
      case definition: TastyTypeDefinition => Some(updateTypeDefinition(definition))
      case _ => Some(statement)
    }

  private def updateTemplate(template: TastyTemplate): TastyTemplate =
    template.copy(
      parents = template.parents.map {
        case apply: TastyTerm.Apply => apply.copy(arguments = apply.arguments.map(_ => `???identifier`))
        case block: TastyTerm.Block => block.copy(statements = block.statements.flatMap(updateStatement))
        case parent => parent
      },
      statements = template.statements.flatMap(updateStatement),
    )

  private def updateTopLevelStatement(statement: TastyTopLevelStatement): Option[TastyTopLevelStatement] =
    statement match {
      case statement: TastyPackageStatement =>
        Some(statement.copy(topLevelStatements = statement.topLevelStatements.flatMap(updateTopLevelStatement)))

      case statement: TastyStatement => updateStatement(statement)
    }

  private def updateTypeDefinition(definition: TastyTypeDefinition): TastyTypeDefinition = definition match {
    case TastyTypeDefinition(name, template: TastyTemplate, information, modifiers) =>
      TastyTypeDefinition(name, updateTemplate(template), information, modifiers)

    case _ => definition
  }

  private def updateValOrDefDefinition(definition: TastyValOrDefDefinition): Option[TastyValOrDefDefinition] = {
    val modifiers = definition match {
      case definition: TastyValOrDefDefinition.Def => definition.modifiers
      case definition: TastyValOrDefDefinition.Val => definition.modifiers
    }

    val isObject = modifiers.exists {
      case _: TastyModifier.Object => true
      case _ => false
    }

    lazy val isPrivate = modifiers.exists {
      case _: TastyModifier.Private => true
      case _ => false
    }

    lazy val isInline = modifiers.exists {
      case _: TastyModifier.Inline => true
      case _ => false
    }

    if (!isObject && isPrivate && !isInline) {
      None
    } else {
      definition match {
        case TastyValOrDefDefinition.Val(name, tastyType, Some(_), modifiers, information) =>
          Some(TastyValOrDefDefinition.Val(name, tastyType, Some(`???identifier`), modifiers, information))

        case TastyValOrDefDefinition.Def(name, parameters, tastyType, Some(_), modifiers, information) =>
          Some(TastyValOrDefDefinition.Def(name, parameters, tastyType, Some(`???identifier`), modifiers, information))

        case _ => Some(definition)
      }
    }
  }

  lazy val updatedTasty: Tasty = {
    val updatedAstsSection = oldTasty.astsSection.map(updateAstsSection)
    val updatedNameTable = TastyNameTable(oldTasty.nameTable.names ++ addedNames)

    oldTasty.copy(
      uuid = new UUID(0, 0),
      nameTable = updatedNameTable,
      astsSection = updatedAstsSection,
      positionsSection = None,
      commentsSection = None,
    )
  }
}

private object TastyUpdater {
  private def getUsedNameIndices(tasty: Tasty): Set[Int] = {
    val usedInSections = tasty.astsSection.map(getUsedNameIndicesInSection).getOrElse(Iterable.empty) ++
      tasty.positionsSection.map(getUsedNameIndicesInSection).getOrElse(Iterable.empty) ++
      tasty.attributesSection.map(getUsedNameIndicesInSection).getOrElse(Iterable.empty)

    // I'm pretty sure the graph of name dependencies is acyclic, so a standard depth-first search should work
    val result = mutable.Set.empty[Int]
    val stack = mutable.ArrayBuffer.from(usedInSections)

    while (stack.nonEmpty) {
      val i = stack.remove(stack.length - 1)

      if (!result(i)) {
        result += i

        TastyElement.collect(tasty.nameTable.names(i)) { case TastyNameReference(j, _) => stack += j }.foreach { _ => }
      }
    }

    result.toSet
  }

  private def getUsedNameIndicesInSection[A <: TastySectionPayload](
    section: TastySection[A],
  )(using TastyElement[TastySection[A]]): Iterable[Int] =
    TastyElement.collect(section) { case TastyNameReference(i, _) => i }

  private def removeDanglingSharedValues[A: TastyElement](
    node: A,
    handledReferences: mutable.Set[TastyReference[? <: MarkerType, ?]],
    oldTastyDereferencer: TastyDereferencer,
    updatedTastyDeferencer: TastyDereferencer,
  ): A = {
    val sharedReference = node match {
      case TastyPath.Shared(reference, _) => Some(reference)
      case TastyTerm.Shared(reference, _) => Some(reference)
      case TastyType.Shared(reference, _) => Some(reference)
      case TastyTypeTree.Shared(reference, _) => Some(reference)
      case _ => None
    }

    sharedReference
      .map { reference =>
        if (handledReferences(reference) || updatedTastyDeferencer.isValidReference(reference)) {
          node
        } else {
          handledReferences += reference

          /**
           * None of the AST nodes reference types more specific than [[TastyPath]], [[TastyTerm]], [[TastyType]], or
           * [[TastyTypeTree]], but the compiler doesn't know that, so we cast the updated value to [[A]].
           */
          val dereferenced =
            oldTastyDereferencer.dereference(reference.asInstanceOf[TastyReference[? <: MarkerType, A]])

          removeDanglingSharedValues(dereferenced, handledReferences, oldTastyDereferencer, updatedTastyDeferencer)
        }
      }
      .getOrElse(
        TastyElement.map(node)(
          [B] =>
            child => removeDanglingSharedValues(child, handledReferences, oldTastyDereferencer, updatedTastyDeferencer),
        ),
      )
  }

  /**
   * Remove shared paths, terms, types, and type trees whose referenced values don't exist in a given [[Tasty]]. I
   * believe the compiler shares these nodes to save space, even when the shared values aren't linked in any way.
   * However, since dottyijar removes private methods and method implementations, it's possible that some shared values'
   * referenced values could be deleted, rendering the references dangling. In this situation, we "inline" one of the
   * shared values so that the others can reference it.
   */
  private def removeDanglingSharedValuesFromTasty(oldTasty: Tasty, updatedTasty: Tasty): Tasty = updatedTasty.copy(
    astsSection = updatedTasty.astsSection
      .map { section =>
        section.copy(
          payload = removeDanglingSharedValues(
            section.payload,
            handledReferences = mutable.Set.empty,
            oldTastyDereferencer = TastyDereferencer(oldTasty),
            updatedTastyDeferencer = TastyDereferencer(updatedTasty),
          ),
        )
      },
  )

  private def removeUnusedNames(tasty: Tasty): Tasty = {
    val usedNameIndices = getUsedNameIndices(tasty)
    val nameIndexUpdates = usedNameIndices.toList.sorted.view.zipWithIndex.toMap

    def updateNameReferences[A: TastyElement](element: A): A = TastyElement.map(element) {
      [B] =>
        child =>
          child match {
            case TastyNameReference(i, information) =>
              TastyNameReference(nameIndexUpdates(i).taggedWith[Unsigned], information).asInstanceOf[B]

            case _ => updateNameReferences(child)
        }
    }

    updateNameReferences(
      tasty.copy(
        nameTable = TastyNameTable(
          tasty.nameTable.names.zipWithIndex.collect { case (name, i) if usedNameIndices(i) => name },
        ),
      ),
    )
  }

  def updateTastyFile(content: Array[Byte]): Array[Byte] = {
    val oldTasty = Tasty.read(content)
    val updatedTasty = new ContextualTastyUpdater(oldTasty).updatedTasty
    val withoutSharedValues = removeDanglingSharedValuesFromTasty(oldTasty, updatedTasty)
    val withoutUnusedNames = removeUnusedNames(withoutSharedValues)

    withoutUnusedNames.write
  }
}
