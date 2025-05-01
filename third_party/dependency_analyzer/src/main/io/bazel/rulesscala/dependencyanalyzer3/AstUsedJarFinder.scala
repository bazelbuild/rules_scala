package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.core.{Annotations, Flags, NameKinds, StdNames}

import scala.collection.mutable
import dotty.tools.io.AbstractFile
import dotty.tools.dotc.util.SourcePosition
import dotty.tools.dotc.core.Types.Type
import dotty.tools.dotc.core.Constants.*
import dotty.tools.dotc.core.Contexts.*
import dotty.tools.dotc.core.Symbols.*
import dotty.tools.dotc.core.Annotations.Annotation
import dotty.tools.dotc.ast.tpd.*
import dotty.tools.dotc.core.StdNames.nme

extension (value: String) {
  def isTastyFile: Boolean = value.endsWith(".tasty")
  def isClassFile: Boolean = value.endsWith(".class")
}

class AstUsedJarFinder {
  def findUsedJars(using Context): Map[AbstractFile, SourcePosition] = {
    val jars = collection.mutable.Map[AbstractFile, SourcePosition]()
    val visitedTrees = mutable.Set.empty[Tree]

    def recordUse(source: AbstractFile, pos: SourcePosition): Unit = {
      // We prefer to report locations which have information (e.g.
      // we don't want NoPosition).
      if !jars.get(source).exists(_.exists) then
        jars.put(source, pos)
    }

    def handleType(tpe: Type, pos: SourcePosition)(using Context): Unit =
      handleSymbol(tpe.typeSymbol, pos)

    def handleSymbol(sym: Symbol, pos: SourcePosition)(using Context): Unit = if sym.exists then {
      val assocFile = sym.associatedFile
      if assocFile != null then
        val path = assocFile.nn.path
        if path.isTastyFile || path.isClassFile then
          assocFile.underlyingSource // use .jar if defined
          .orElse(Some(assocFile))   // or .class/.tasty file otherwise
          .foreach(recordUse(_, pos))
    }

    def exploreType(tpe: Type, pos: SourcePosition): Unit = {
      handleType(tpe, pos)
      for
        paramList <- tpe.paramInfoss
        param <- paramList
      do
        exploreType(param, pos)
    }

    def fullyExploreTree(tree: Tree): Unit = {
      def visitNode(tree: Tree): Unit = {
        val shouldExamine = tree match {
          case tree: Select =>
            tree.symbol.name match
              case NameKinds.DefaultGetterName(_, _) => false
              case _ => true
          case _ => true
        }
        if !shouldExamine then return

        // Tree specific handliong
        tree match {
          case tree: TypeTree =>
            fullyExploreTree(tree.underlying)

          case Literal(Constant(tpe: Type)) => exploreType(tpe, tree.sourcePos)

          case Inlined(call, bindings, expansion) =>
            fullyExploreTree(call)
            bindings.foreach(fullyExploreTree)
            fullyExploreTree(expansion)

          case Import(qualifier, selectors) =>
            val symbol = qualifier.symbol
            selectors.foreach { selector =>
              if selector.name != nme.WILDCARD && selector.rename != nme.WILDCARD then
                val selected = symbol.info.member(selector.name).symbol
                handleSymbol(selected, tree.sourcePos)
            }
          case _ => // skip
        }

        // We skip annotations without positions. The reason for
        // this is the case of
        //   @SomeAnnotation class A
        //   class B extends A
        // Now assuming A and B are in separate packages, while
        // examining B we will examine A as well, and hence
        // examine A's annotations. However we don't wish to examine
        // A's annotations as we don't care about those details of A.
        // Hence we only examine annotations with positions (hence,
        // they were defined in the same compilation unit and thus
        // matter).
        if tree.symbol.exists then {
          tree.symbol.annotations
            .filter(_.tree.sourcePos.exists)
            .filterNot(_.symbol.showFullName.startsWith("scala.annotation.internal."))
            .foreach { annot =>
              fullyExploreTree(annot.tree)
            }
        }
        // Generic tree traversal
        if tree.hasType then
          exploreType(tree.tpe, tree.sourcePos)
      }

      // handle possible cycles in macro expandees
      if (!visitedTrees.contains(tree)) {
        visitedTrees += tree
        tree.foreachSubTree(visitNode)
      }
    }

    ctx.run.units.foreach { unit =>
      fullyExploreTree(unit.tpdTree)
    }

    jars.toMap
  }
}
