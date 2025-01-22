package io.bazel.rules_scala.dottyijar.tasty

import dotty.tools.dotc.util.Spans.Span
import dotty.tools.tasty.TastyFormat as DottyTastyFormat
import io.bazel.rules_scala.dottyijar.tasty.format.*
import io.bazel.rules_scala.dottyijar.tasty.numeric.{SignedInt, SignedLong, UnsignedInt}
import java.util.UUID
import scala.annotation.nowarn
import scala.util.control.NonFatal

case class Tasty(
  majorVersion: UnsignedInt,
  minorVersion: UnsignedInt,
  experimentalVersion: UnsignedInt,
  versionString: String,
  uuid: UUID,
  nameTable: TastyNameTable,
  astsSection: Option[TastySection[TastySectionPayload.Asts]],
  positionsSection: Option[TastySection[TastySectionPayload.Positions]],
  commentsSection: Option[TastySection[TastySectionPayload.Comments]],
  attributesSection: Option[TastySection[TastySectionPayload.Attributes]],
) {
  def write: Array[Byte] = {
    val writer = TastyWriter.empty

    summon[TastyFormat[Tasty]].write(writer, this)

    writer.fillInReferences()
    writer.toArray
  }
}

object Tasty {
  def apply(
    majorVersion: UnsignedInt,
    minorVersion: UnsignedInt,
    experimentalVersion: UnsignedInt,
    versionString: String,
    uuid: UUID,
    nameTable: TastyNameTable,
    sections: List[TastySection[? <: TastySectionPayload]],
  ): Tasty = {
    val astsSection: Option[TastySection[TastySectionPayload.Asts]] = sections.collectFirst {
      case TastySection(name, payload: TastySectionPayload.Asts) => TastySection(name, payload)
    }

    val positionsSection: Option[TastySection[TastySectionPayload.Positions]] = sections.collectFirst {
      case TastySection(name, payload: TastySectionPayload.Positions) => TastySection(name, payload)
    }

    val commentsSection: Option[TastySection[TastySectionPayload.Comments]] = sections.collectFirst {
      case TastySection(name, payload: TastySectionPayload.Comments) => TastySection(name, payload)
    }

    val attributesSection: Option[TastySection[TastySectionPayload.Attributes]] = sections.collectFirst {
      case TastySection(name, payload: TastySectionPayload.Attributes) => TastySection(name, payload)
    }

    Tasty(
      majorVersion,
      minorVersion,
      experimentalVersion,
      versionString,
      uuid,
      nameTable,
      astsSection,
      positionsSection,
      commentsSection,
      attributesSection,
    )
  }

  def read(encoded: Array[Byte]): Tasty = {
    val reader = TastyReader(encoded)
    val result = summon[TastyFormat[Tasty]].read(reader)

    reader.linkReferences()

    result
  }

  given TastyFormat[Tasty] = TastyFormat(
    reader => {
      reader.readMagicNumber()

      val majorVersion = summon[TastyFormat[UnsignedInt]].read(reader)
      val minorVersion = summon[TastyFormat[UnsignedInt]].read(reader)
      val experimentalVersion = summon[TastyFormat[UnsignedInt]].read(reader)
      val versionString = summon[TastyFormat[String]].read(reader)
      val uuid = summon[TastyFormat[UUID]].read(reader)
      val nameTable = summon[TastyFormat[TastyNameTable]].read(reader)
      val sectionTastyFormat = TastySection.tastyFormat(nameTable)
      val sections = reader.readUntilEnd(sectionTastyFormat.read(reader))

      Tasty(majorVersion, minorVersion, experimentalVersion, versionString, uuid, nameTable, sections)
    },
    (writer, tasty) => {
      writer.writeMagicNumber()

      summon[TastyFormat[UnsignedInt]].write(writer, tasty.majorVersion)
      summon[TastyFormat[UnsignedInt]].write(writer, tasty.minorVersion)
      summon[TastyFormat[UnsignedInt]].write(writer, tasty.experimentalVersion)
      summon[TastyFormat[String]].write(writer, tasty.versionString)
      summon[TastyFormat[UUID]].write(writer, tasty.uuid)
      summon[TastyFormat[TastyNameTable]].write(writer, tasty.nameTable)

      val sectionTastyFormat = TastySection.tastyFormat(tasty.nameTable)

      tasty.astsSection.foreach(sectionTastyFormat.write(writer, _))
      tasty.positionsSection.foreach(sectionTastyFormat.write(writer, _))
      tasty.commentsSection.foreach(sectionTastyFormat.write(writer, _))
      tasty.attributesSection.foreach(sectionTastyFormat.write(writer, _))
    },
  )
}

case class TastyCaseDefinition(
  pattern: TastyTerm,
  rightHandSide: TastyTerm,
  override var information: TastyReferencableInformation,
  guard: Option[TastyTerm],
) extends TastyReferencable

object TastyCaseDefinition {
  private given TastyFormat[(TastyTerm, TastyTerm, TastyReferencableInformation, Option[TastyTerm])] =
    TastyFormat.forOptional[(TastyTerm, TastyTerm, TastyReferencableInformation), TastyTerm]

  given TastySumType[TastyCaseDefinition] =
    TastySumType.withSingleVariant(DottyTastyFormat.CASEDEF, TastyFormat.forProduct[TastyCaseDefinition])

  given TastyFormat[TastyCaseDefinition] = TastyFormat.forSumType
}

sealed trait TastyConstant extends TastyPath with TastyReferencable

object TastyConstant {
  given TastySumType[TastyConstant] = new TastySumType(
    TastySumType.Variant[TastyUnitConstant](DottyTastyFormat.UNITconst),
    TastySumType.Variant[TastyFalseConstant](DottyTastyFormat.FALSEconst),
    TastySumType.Variant[TastyTrueConstant](DottyTastyFormat.TRUEconst),
    TastySumType.Variant[TastyByteConstant](DottyTastyFormat.BYTEconst),
    TastySumType.Variant[TastyShortConstant](DottyTastyFormat.SHORTconst),
    TastySumType.Variant[TastyCharConstant](DottyTastyFormat.CHARconst),
    TastySumType.Variant[TastyIntConstant](DottyTastyFormat.INTconst),
    TastySumType.Variant[TastyLongConstant](DottyTastyFormat.LONGconst),
    TastySumType.Variant[TastyFloatConstant](DottyTastyFormat.FLOATconst),
    TastySumType.Variant[TastyDoubleConstant](DottyTastyFormat.DOUBLEconst),
    TastySumType.Variant[TastyStringConstant](DottyTastyFormat.STRINGconst),
    TastySumType.Variant[TastyNullConstant](DottyTastyFormat.NULLconst),
    TastySumType.Variant[TastyClassConstant](DottyTastyFormat.CLASSconst),
  )

  given TastyFormat[TastyConstant] = TastyFormat.forSumType
}

case class TastyUnitConstant(override var information: TastyReferencableInformation = TastyReferencableInformation())
    extends TastyConstant

object TastyUnitConstant {
  given TastyFormat[TastyUnitConstant] = TastyFormat.forProduct
}

case class TastyFalseConstant(override var information: TastyReferencableInformation = TastyReferencableInformation())
    extends TastyConstant

object TastyFalseConstant {
  given TastyFormat[TastyFalseConstant] = TastyFormat.forProduct
}

case class TastyTrueConstant(override var information: TastyReferencableInformation = TastyReferencableInformation())
    extends TastyConstant

object TastyTrueConstant {
  given TastyFormat[TastyTrueConstant] = TastyFormat.forProduct
}

case class TastyByteConstant(
  value: SignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyByteConstant {
  given TastyFormat[TastyByteConstant] = TastyFormat.forProduct
}

case class TastyShortConstant(
  value: SignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyShortConstant {
  given TastyFormat[TastyShortConstant] = TastyFormat.forProduct
}

case class TastyCharConstant(
  value: UnsignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyCharConstant {
  given TastyFormat[TastyCharConstant] = TastyFormat.forProduct
}

case class TastyIntConstant(
  value: SignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyIntConstant {
  given TastyFormat[TastyIntConstant] = TastyFormat.forProduct
}

case class TastyLongConstant(
  value: SignedLong,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyLongConstant {
  given TastyFormat[TastyLongConstant] = TastyFormat.forProduct
}

case class TastyFloatConstant(
  value: SignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyFloatConstant {
  given TastyFormat[TastyFloatConstant] = TastyFormat.forProduct
}

case class TastyDoubleConstant(
  value: SignedLong,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyDoubleConstant {
  given TastyFormat[TastyDoubleConstant] = TastyFormat.forProduct
}

case class TastyStringConstant(
  value: TastyNameReference,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyStringConstant {
  given TastyFormat[TastyStringConstant] = TastyFormat.forProduct
}

case class TastyNullConstant(override var information: TastyReferencableInformation = TastyReferencableInformation())
    extends TastyConstant

object TastyNullConstant {
  given TastyFormat[TastyNullConstant] = TastyFormat.forProduct
}

case class TastyClassConstant(
  typeArgument: TastyType,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyConstant

object TastyClassConstant {
  given TastyFormat[TastyClassConstant] = TastyFormat.forProduct
}

case class TastyImplicitArgument(
  argument: TastyTerm,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyReferencable

object TastyImplicitArgument {
  given TastySumType[TastyImplicitArgument] =
    TastySumType.withSingleVariant(DottyTastyFormat.IMPLICITarg, TastyFormat.forProduct[TastyImplicitArgument])

  given TastyFormat[TastyImplicitArgument] = TastyFormat.forSumType
}

sealed trait TastyModifier extends TastyReferencable

object TastyModifier {
  case class Private(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Private {
    given TastyFormat[Private] = TastyFormat.forProduct
  }

  case class Protected(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Protected {
    given TastyFormat[Protected] = TastyFormat.forProduct
  }

  case class PrivateQualified(
    qualifier: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyModifier

  object PrivateQualified {
    given TastyFormat[PrivateQualified] = TastyFormat.forProduct
  }

  case class ProtectedQualified(
    qualifier: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyModifier

  object ProtectedQualified {
    given TastyFormat[ProtectedQualified] = TastyFormat.forProduct
  }

  case class Abstract(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Abstract {
    given TastyFormat[Abstract] = TastyFormat.forProduct
  }

  case class Final(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Final {
    given TastyFormat[Final] = TastyFormat.forProduct
  }

  case class Sealed(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Sealed {
    given TastyFormat[Sealed] = TastyFormat.forProduct
  }

  case class Case(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Case {
    given TastyFormat[Case] = TastyFormat.forProduct
  }

  case class Implicit(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Implicit {
    given TastyFormat[Implicit] = TastyFormat.forProduct
  }

  case class Given(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Given {
    given TastyFormat[Given] = TastyFormat.forProduct
  }

  case class Erased(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Erased {
    given TastyFormat[Erased] = TastyFormat.forProduct
  }

  case class Lazy(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Lazy {
    given TastyFormat[Lazy] = TastyFormat.forProduct
  }

  case class Override(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Override {
    given TastyFormat[Override] = TastyFormat.forProduct
  }

  case class Opaque(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Opaque {
    given TastyFormat[Opaque] = TastyFormat.forProduct
  }

  case class Inline(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Inline {
    given TastyFormat[Inline] = TastyFormat.forProduct
  }

  case class Macro(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Macro {
    given TastyFormat[Macro] = TastyFormat.forProduct
  }

  case class InlineProxy(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object InlineProxy {
    given TastyFormat[InlineProxy] = TastyFormat.forProduct
  }

  case class Static(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Static {
    given TastyFormat[Static] = TastyFormat.forProduct
  }

  case class Object(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Object {
    given TastyFormat[Object] = TastyFormat.forProduct
  }

  case class Trait(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Trait {
    given TastyFormat[Trait] = TastyFormat.forProduct
  }

  case class Enum(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Enum {
    given TastyFormat[Enum] = TastyFormat.forProduct
  }

  case class Local(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Local {
    given TastyFormat[Local] = TastyFormat.forProduct
  }

  case class Synthetic(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Synthetic {
    given TastyFormat[Synthetic] = TastyFormat.forProduct
  }

  case class Artifact(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Artifact {
    given TastyFormat[Artifact] = TastyFormat.forProduct
  }

  case class Mutable(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Mutable {
    given TastyFormat[Mutable] = TastyFormat.forProduct
  }

  case class FieldAccessor(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object FieldAccessor {
    given TastyFormat[FieldAccessor] = TastyFormat.forProduct
  }

  case class CaseAccessor(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object CaseAccessor {
    given TastyFormat[CaseAccessor] = TastyFormat.forProduct
  }

  case class Covariant(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Covariant {
    given TastyFormat[Covariant] = TastyFormat.forProduct
  }

  case class Contravariant(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Contravariant {
    given TastyFormat[Contravariant] = TastyFormat.forProduct
  }

  case class HasDefault(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object HasDefault {
    given TastyFormat[HasDefault] = TastyFormat.forProduct
  }

  case class Stable(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Stable {
    given TastyFormat[Stable] = TastyFormat.forProduct
  }

  case class Extension(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Extension {
    given TastyFormat[Extension] = TastyFormat.forProduct
  }

  case class ParameterSetter(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object ParameterSetter {
    given TastyFormat[ParameterSetter] = TastyFormat.forProduct
  }

  case class ParameterAlias(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object ParameterAlias {
    given TastyFormat[ParameterAlias] = TastyFormat.forProduct
  }

  case class Exported(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Exported {
    given TastyFormat[Exported] = TastyFormat.forProduct
  }

  case class Open(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Open {
    given TastyFormat[Open] = TastyFormat.forProduct
  }

  case class Invisible(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Invisible {
    given TastyFormat[Invisible] = TastyFormat.forProduct
  }

  case class Tracked(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Tracked {
    given TastyFormat[Tracked] = TastyFormat.forProduct
  }

  case class Annotation(
    `type`: TastyType,
    value: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyModifier

  object Annotation {
    given TastyFormat[Annotation] = TastyFormat.forProduct[Annotation].withLengthPrefixed
  }

  /**
   * This isn't formally documented in the TASTy grammar as a modifier, but you can find it here:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L757]]
   */
  case class Transparent(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Transparent {
    given TastyFormat[Transparent] = TastyFormat.forProduct
  }

  /**
   * This isn't formally documented in the TASTy grammar as a modifier, but you can find it here:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L758]]
   */
  case class Infix(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyModifier

  object Infix {
    given TastyFormat[Infix] = TastyFormat.forProduct
  }

  given TastySumType[TastyModifier] = new TastySumType(
    TastySumType.Variant[Private](DottyTastyFormat.PRIVATE),
    TastySumType.Variant[Protected](DottyTastyFormat.PROTECTED),
    TastySumType.Variant[PrivateQualified](DottyTastyFormat.PRIVATEqualified),
    TastySumType.Variant[ProtectedQualified](DottyTastyFormat.PROTECTEDqualified),
    TastySumType.Variant[Abstract](DottyTastyFormat.ABSTRACT),
    TastySumType.Variant[Final](DottyTastyFormat.FINAL),
    TastySumType.Variant[Sealed](DottyTastyFormat.SEALED),
    TastySumType.Variant[Case](DottyTastyFormat.CASE),
    TastySumType.Variant[Implicit](DottyTastyFormat.IMPLICIT),
    TastySumType.Variant[Given](DottyTastyFormat.GIVEN),
    TastySumType.Variant[Erased](DottyTastyFormat.ERASED),
    TastySumType.Variant[Lazy](DottyTastyFormat.LAZY),
    TastySumType.Variant[Override](DottyTastyFormat.OVERRIDE),
    TastySumType.Variant[Opaque](DottyTastyFormat.OPAQUE),
    TastySumType.Variant[Inline](DottyTastyFormat.INLINE),
    TastySumType.Variant[Macro](DottyTastyFormat.MACRO),
    TastySumType.Variant[InlineProxy](DottyTastyFormat.INLINEPROXY),
    TastySumType.Variant[Static](DottyTastyFormat.STATIC),
    TastySumType.Variant[Object](DottyTastyFormat.OBJECT),
    TastySumType.Variant[Trait](DottyTastyFormat.TRAIT),
    TastySumType.Variant[Enum](DottyTastyFormat.ENUM),
    TastySumType.Variant[Local](DottyTastyFormat.LOCAL),
    TastySumType.Variant[Synthetic](DottyTastyFormat.SYNTHETIC),
    TastySumType.Variant[Artifact](DottyTastyFormat.ARTIFACT),
    TastySumType.Variant[Mutable](DottyTastyFormat.MUTABLE),
    TastySumType.Variant[FieldAccessor](DottyTastyFormat.FIELDaccessor),
    TastySumType.Variant[CaseAccessor](DottyTastyFormat.CASEaccessor),
    TastySumType.Variant[Covariant](DottyTastyFormat.COVARIANT),
    TastySumType.Variant[Contravariant](DottyTastyFormat.CONTRAVARIANT),
    TastySumType.Variant[HasDefault](DottyTastyFormat.HASDEFAULT),
    TastySumType.Variant[Stable](DottyTastyFormat.STABLE),
    TastySumType.Variant[Extension](DottyTastyFormat.EXTENSION),
    TastySumType.Variant[ParameterSetter](DottyTastyFormat.PARAMsetter),
    TastySumType.Variant[ParameterAlias](DottyTastyFormat.PARAMalias),
    TastySumType.Variant[Exported](DottyTastyFormat.EXPORTED),
    TastySumType.Variant[Open](DottyTastyFormat.OPEN),
    TastySumType.Variant[Invisible](DottyTastyFormat.INVISIBLE),
    TastySumType.Variant[Tracked](DottyTastyFormat.TRACKED),
    TastySumType.Variant[Annotation](DottyTastyFormat.ANNOTATION),
    TastySumType.Variant[Transparent](DottyTastyFormat.TRANSPARENT),
    TastySumType.Variant[Infix](DottyTastyFormat.INFIX),
  )

  given TastyFormat[TastyModifier] = TastyFormat.forSumType
}

sealed trait TastyName extends TastyReferencable

object TastyName {
  case class Simple(
    name: String,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object Simple {
    given TastyFormat[Simple] = TastyFormat.forProduct
  }

  case class Qualified(
    qualified: TastyNameReference,
    selector: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object Qualified {
    given TastyFormat[Qualified] = TastyFormat.forProduct[Qualified].withLengthPrefixed
  }

  case class Expanded(
    qualified: TastyNameReference,
    selector: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object Expanded {
    given TastyFormat[Expanded] = TastyFormat.forProduct[Expanded].withLengthPrefixed
  }

  case class ExpandPrefix(
    qualified: TastyNameReference,
    selector: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object ExpandPrefix {
    given TastyFormat[ExpandPrefix] = TastyFormat.forProduct[ExpandPrefix].withLengthPrefixed
  }

  case class Unique(
    separator: TastyNameReference,
    uniqueId: UnsignedInt,
    override var information: TastyReferencableInformation,
    underlying: Option[TastyNameReference],
  ) extends TastyName

  object Unique {
    private given TastyFormat[
      (TastyNameReference, UnsignedInt, TastyReferencableInformation, Option[TastyNameReference]),
    ] = TastyFormat.forOptional[(TastyNameReference, UnsignedInt, TastyReferencableInformation), TastyNameReference]

    given TastyFormat[Unique] = TastyFormat.forProduct
  }

  case class DefaultGetter(
    underlying: TastyNameReference,
    index: UnsignedInt,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object DefaultGetter {
    given TastyFormat[DefaultGetter] = TastyFormat.forProduct[DefaultGetter].withLengthPrefixed
  }

  case class SuperAccessor(
    underlying: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object SuperAccessor {
    given TastyFormat[SuperAccessor] = TastyFormat.forProduct[SuperAccessor].withLengthPrefixed
  }

  case class InlineAccessor(
    underlying: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object InlineAccessor {
    given TastyFormat[InlineAccessor] = TastyFormat.forProduct[InlineAccessor].withLengthPrefixed
  }

  case class ObjectClass(
    underlying: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object ObjectClass {
    given TastyFormat[ObjectClass] = TastyFormat.forProduct[ObjectClass].withLengthPrefixed
  }

  case class BodyRetainer(
    underlying: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyName

  object BodyRetainer {
    given TastyFormat[BodyRetainer] = TastyFormat.forProduct[BodyRetainer].withLengthPrefixed
  }

  case class Signed(
    original: TastyNameReference,
    resultSignature: TastyNameReference,
    override var information: TastyReferencableInformation,
    parameterSignatures: List[TastyParameterSignature],
  ) extends TastyName

  object Signed {
    given TastyFormat[
      (TastyNameReference, TastyNameReference, TastyReferencableInformation, List[TastyParameterSignature]),
    ] = TastyFormat.forVariadic[
      (TastyNameReference, TastyNameReference, TastyReferencableInformation),
      TastyParameterSignature,
      List[TastyParameterSignature],
    ]

    given TastyFormat[Signed] = TastyFormat.forProduct
  }

  case class TargetSigned(
    original: TastyNameReference,
    target: TastyNameReference,
    resultSignature: TastyNameReference,
    override var information: TastyReferencableInformation,
    parameterSignatures: List[TastyParameterSignature],
  ) extends TastyName

  object TargetSigned {
    given TastyFormat[
      (
        TastyNameReference,
        TastyNameReference,
        TastyNameReference,
        TastyReferencableInformation,
        List[TastyParameterSignature],
      ),
    ] = TastyFormat.forVariadic[
      (TastyNameReference, TastyNameReference, TastyNameReference, TastyReferencableInformation),
      TastyParameterSignature,
      List[TastyParameterSignature],
    ]

    given TastyFormat[TargetSigned] = TastyFormat.forProduct
  }

  given TastySumType[TastyName] = new TastySumType(
    TastySumType.Variant[Simple](DottyTastyFormat.NameTags.UTF8),
    TastySumType.Variant[Qualified](DottyTastyFormat.NameTags.QUALIFIED),
    TastySumType.Variant[Expanded](DottyTastyFormat.NameTags.EXPANDED),
    TastySumType.Variant[ExpandPrefix](DottyTastyFormat.NameTags.EXPANDPREFIX),
    TastySumType.Variant[Unique](DottyTastyFormat.NameTags.UNIQUE),
    TastySumType.Variant[DefaultGetter](DottyTastyFormat.NameTags.DEFAULTGETTER),
    TastySumType.Variant[SuperAccessor](DottyTastyFormat.NameTags.SUPERACCESSOR),
    TastySumType.Variant[InlineAccessor](DottyTastyFormat.NameTags.INLINEACCESSOR),
    TastySumType.Variant[ObjectClass](DottyTastyFormat.NameTags.OBJECTCLASS),
    TastySumType.Variant[BodyRetainer](DottyTastyFormat.NameTags.BODYRETAINER),
    TastySumType.Variant[Signed](DottyTastyFormat.NameTags.SIGNED),
    TastySumType.Variant[TargetSigned](DottyTastyFormat.NameTags.TARGETSIGNED),
  )

  given TastyFormat[TastyName] = TastyFormat.forSumType
}

case class TastyNameReference(
  i: UnsignedInt,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyReferencable

object TastyNameReference {
  given TastyFormat[TastyNameReference] = TastyFormat.forProduct
}

sealed trait TastyParameter extends TastySymbol with TastyReferencable

object TastyParameter {
  case class EmptyClause(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyParameter

  object EmptyClause {
    given TastyFormat[EmptyClause] = TastyFormat.forProduct
  }

  case class SplitClause(override var information: TastyReferencableInformation = TastyReferencableInformation())
      extends TastyParameter

  object SplitClause {
    given TastyFormat[SplitClause] = TastyFormat.forProduct
  }

  given TastySumType[TastyParameter] = summon[TastySumType[TastyTypeParameter]]
    .or(summon[TastySumType[TastyTermParameter]])
    .or(
      new TastySumType(
        TastySumType.Variant[EmptyClause](DottyTastyFormat.EMPTYCLAUSE),
        TastySumType.Variant[SplitClause](DottyTastyFormat.SPLITCLAUSE),
      ),
    )

  given TastyFormat[TastyParameter] = TastyFormat.forSumType
}

case class TastyTypeParameter(
  name: TastyNameReference,
  `type`: TastyTypeTree,
  override var information: TastyReferencableInformation,
  modifiers: List[TastyModifier],
) extends TastyParameter

object TastyTypeParameter {
  private given TastyFormat[(TastyNameReference, TastyTypeTree, TastyReferencableInformation, List[TastyModifier])] =
    TastyFormat.forVariadic[
      (TastyNameReference, TastyTypeTree, TastyReferencableInformation),
      TastyModifier,
      List[TastyModifier],
    ]

  given TastySumType[TastyTypeParameter] =
    TastySumType.withSingleVariant(DottyTastyFormat.TYPEPARAM, TastyFormat.forProduct[TastyTypeParameter])

  given TastyFormat[TastyTypeParameter] = TastyFormat.forSumType
}

case class TastyTermParameter(
  name: TastyNameReference,
  `type`: TastyTypeTree,
  override var information: TastyReferencableInformation,
  modifiers: List[TastyModifier],
) extends TastyParameter

object TastyTermParameter {
  private given TastyFormat[(TastyNameReference, TastyTypeTree, TastyReferencableInformation, List[TastyModifier])] =
    TastyFormat.forVariadic[
      (TastyNameReference, TastyTypeTree, TastyReferencableInformation),
      TastyModifier,
      List[TastyModifier],
    ]

  given TastySumType[TastyTermParameter] =
    TastySumType.withSingleVariant(DottyTastyFormat.PARAM, TastyFormat.forProduct[TastyTermParameter])

  given TastyFormat[TastyTermParameter] = TastyFormat.forSumType
}

sealed trait TastyParameterSignature extends TastyReferencable

object TastyParameterSignature {
  case class TypeParameterSectionLength(
    length: Int,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyParameterSignature

  case class TermParameter(
    name: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyParameterSignature

  given TastyFormat[TastyParameterSignature] = TastyFormat(
    reader => {
      val value = reader.readSignedInt().value

      if (value < 0) {
        TypeParameterSectionLength(-value)
      } else {
        TermParameter(TastyNameReference(UnsignedInt(value)))
      }
    },
    (writer, value) =>
      value match {
        case TypeParameterSectionLength(length, _) => writer.writeSignedInt(SignedInt(-length))
        case TermParameter(name, _) => writer.writeSignedInt(SignedInt(name.i.value))
      },
  )
}

sealed trait TastyPath extends TastyTerm with TastyType with TastyReferencable

object TastyPath {
  case class LocalReference(
    reference: TastyAstReference[TastySymbol],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object LocalReference {
    given TastyFormat[LocalReference] = TastyFormat.forProduct
  }

  case class PrefixedLocalReference(
    reference: TastyAstReference[TastySymbol],
    qualified: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object PrefixedLocalReference {
    given TastyFormat[PrefixedLocalReference] = TastyFormat.forProduct
  }

  case class PackageReference(
    fullyQualifiedName: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object PackageReference {
    given TastyFormat[PackageReference] = TastyFormat.forProduct
  }

  case class NonLocalReference(
    possiblySignedName: TastyNameReference,
    qualified: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object NonLocalReference {
    given TastyFormat[NonLocalReference] = TastyFormat.forProduct
  }

  case class NonLocalReferenceIn(
    possiblySignedName: TastyNameReference,
    qualified: TastyType,
    owner: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object NonLocalReferenceIn {
    given TastyFormat[NonLocalReferenceIn] = TastyFormat.forProduct
  }

  case class This(
    classReference: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object This {
    given TastyFormat[This] = TastyFormat.forProduct
  }

  case class RecursivelyRefinedThis(
    recursivelyRefinedType: TastyAstReference[TastyType],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object RecursivelyRefinedThis {
    given TastyFormat[RecursivelyRefinedThis] = TastyFormat.forProduct
  }

  case class Shared(
    path: TastyAstReference[TastyPath],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyPath

  object Shared {
    given TastyFormat[Shared] = TastyFormat.forProduct
  }

  given TastySumType[TastyPath] = summon[TastySumType[TastyConstant]].or(
    new TastySumType(
      TastySumType.Variant[LocalReference](DottyTastyFormat.TERMREFdirect),
      TastySumType.Variant[PrefixedLocalReference](DottyTastyFormat.TERMREFsymbol),
      TastySumType.Variant[PackageReference](DottyTastyFormat.TERMREFpkg),
      TastySumType.Variant[NonLocalReference](DottyTastyFormat.TERMREF),
      TastySumType.Variant[NonLocalReferenceIn](DottyTastyFormat.TERMREFin),
      TastySumType.Variant[This](DottyTastyFormat.THIS),
      TastySumType.Variant[RecursivelyRefinedThis](DottyTastyFormat.RECthis),
      TastySumType.Variant[Shared](DottyTastyFormat.SHAREDtype),
    ),
  )

  given TastyFormat[TastyPath] = TastyFormat.forSumType
}

case class TastyNameTable(names: Vector[TastyName]) {
  override def toString: String =
    s"""TastyNameTable(
       |${names.zipWithIndex.map { case (name, i) => s"  $i: $name" }.mkString("\n")}
       |)""".stripMargin

  def apply(reference: TastyNameReference): TastyName = names(reference.i.value)
}

object TastyNameTable {
  given TastyFormat[TastyNameTable] =
    TastyFormat.forIterableWithLengthPrefixed[TastyName, Vector[TastyName]].bimap(TastyNameTable(_), _.names)
}

case class TastySection[A <: TastySectionPayload](name: TastyNameReference, payload: A)

object TastySection {
  def tastyFormat(nameTable: TastyNameTable): TastyFormat[TastySection[? <: TastySectionPayload]] = TastyFormat(
    reader => {
      val nameReference = summon[TastyFormat[TastyNameReference]].read(reader)
      val name = nameTable(nameReference)
      val payload = reader.readWithLength(reader.readUnsignedInt().value) { reader =>
        name match {
          case TastyName.Simple("ASTs", _) => summon[TastyFormat[TastySectionPayload.Asts]].read(reader)
          case TastyName.Simple("Positions", _) => summon[TastyFormat[TastySectionPayload.Positions]].read(reader)
          case TastyName.Simple("Comments", _) => summon[TastyFormat[TastySectionPayload.Comments]].read(reader)
          case TastyName.Simple("Attributes", _) => summon[TastyFormat[TastySectionPayload.Attributes]].read(reader)
          case TastyName.Simple(name, _) => throw new Exception(s"Unrecognized section name: $name")
          case other =>
            throw new Exception(s"Expected a simple string when following a section name reference, but got $other")
        }
      }

      TastySection(nameReference, payload)
    },
    (writer, section) => {
      summon[TastyFormat[TastyNameReference]].write(writer, section.name)

      writer.writeWithLengthPrefixed { writer =>
        section.payload match {
          case asts: TastySectionPayload.Asts =>
            summon[TastyFormat[TastySectionPayload.Asts]].write(writer, asts)

          case positions: TastySectionPayload.Positions =>
            summon[TastyFormat[TastySectionPayload.Positions]].write(writer, positions)

          case comments: TastySectionPayload.Comments =>
            summon[TastyFormat[TastySectionPayload.Comments]].write(writer, comments)

          case attributes: TastySectionPayload.Attributes =>
            summon[TastyFormat[TastySectionPayload.Attributes]].write(writer, attributes)
        }
      }
    },
  )
}

sealed trait TastySectionPayload

object TastySectionPayload {
  case class Asts(topLevelStatements: List[TastyTopLevelStatement]) extends TastySectionPayload

  object Asts {
    given TastyFormat[Asts] = TastyFormat
      .forIterableWithoutLengthPrefixed[TastyTopLevelStatement, List[TastyTopLevelStatement]]
      .bimap(Asts(_), _.topLevelStatements)
      .marked(MarkerType.AstSection)
  }

  case class Positions(lineSizes: Positions.LineSizes, deltas: List[Positions.Delta | Positions.Source])
      extends TastySectionPayload

  object Positions {
    case class LineSizes(sizes: List[UnsignedInt])

    object LineSizes {
      given TastyFormat[LineSizes] = TastyFormat(
        reader => {
          val length = reader.readUnsignedInt().value

          LineSizes(Range(0, length).map(_ => reader.readUnsignedInt()).toList)
        },
        (writer, lineSizes) => {
          writer.writeUnsignedInt(UnsignedInt(lineSizes.sizes.length))

          lineSizes.sizes.foreach(writer.writeUnsignedInt)
        },
      )
    }

    case class Delta(addressDelta: Int, start: Option[SignedInt], end: Option[SignedInt], point: Option[SignedInt])

    object Delta {
      given TastyFormat[Delta] = TastyFormat(
        reader => {
          val header = reader.readUnsignedInt().value
          val addressDelta = header >> 3
          val start = Option.when(((header >>> 2) & 0x1) == 1)(reader.readSignedInt())
          val end = Option.when(((header >>> 1) & 0x1) == 1)(reader.readSignedInt())
          val point = Option.when((header & 0x1) == 1)(reader.readSignedInt())

          Delta(addressDelta, start, end, point)
        },
        (writer, delta) => {
          val header = UnsignedInt(
            (delta.addressDelta << 3) |
              ((if (delta.start.isDefined) 1 else 0) << 2) |
              ((if (delta.end.isDefined) 1 else 0) << 1) |
              (if (delta.point.isDefined) 1 else 0)
          )

          writer.writeUnsignedInt(header)

          delta.start.foreach(writer.writeSignedInt)
          delta.end.foreach(writer.writeSignedInt)
          delta.point.foreach(writer.writeSignedInt)
        },
      )
    }

    case class Source(path: TastyNameReference)

    object Source {
      given TastyFormat[Source] = TastyFormat.forProduct
    }

    private given TastyFormat[Delta | Source] = TastyFormat(
      reader =>
        if (reader.peek(_.readUnsignedInt().value) == DottyTastyFormat.SOURCE) {
          reader.readUnsignedInt()

          summon[TastyFormat[Source]].read(reader)
        } else {
          summon[TastyFormat[Delta]].read(reader)
        },
      (writer, value) =>
        value match {
          case delta: Delta => summon[TastyFormat[Delta]].write(writer, delta)
          case source: Source =>
            writer.writeUnsignedInt(UnsignedInt(DottyTastyFormat.SOURCE))

            summon[TastyFormat[Source]].write(writer, source)
        },
    )

    private given TastyFormat[List[Delta | Source]] = TastyFormat.forIterableWithoutLengthPrefixed

    given TastyFormat[Positions] = TastyFormat.forProduct
  }

  /**
   * The TASTy grammar doesn't mention this, but each comment is prefixed with the address of the symbol to which it
   * belongs:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/CommentUnpickler.scala#L21]]
   */
  case class Comments(comments: List[(TastyAstReference[TastySymbol], Comments.Comment)]) extends TastySectionPayload

  object Comments {
    case class Comment(content: String, coordinates: Span)

    object Comment {
      given TastyFormat[Comment] = TastyFormat.forProduct
    }

    given TastyFormat[Comments] = TastyFormat
      .forIterableWithoutLengthPrefixed[
        (TastyAstReference[TastySymbol], Comment),
        List[(TastyAstReference[TastySymbol], Comment)],
      ]
      .bimap(Comments(_), _.comments)
  }

  case class Attributes(attributes: List[Attributes.Attribute]) extends TastySectionPayload

  object Attributes {
    sealed trait Attribute extends TastyReferencable

    object Attribute {
      case class Scala2StandardLibrary(
        override var information: TastyReferencableInformation = TastyReferencableInformation(),
      ) extends Attribute

      object Scala2StandardLibrary {
        given TastyFormat[Scala2StandardLibrary] = TastyFormat.forProduct
      }

      case class ExplicitNulls(override var information: TastyReferencableInformation = TastyReferencableInformation())
          extends Attribute

      object ExplicitNulls {
        given TastyFormat[ExplicitNulls] = TastyFormat.forProduct
      }

      case class CaptureChecked(override var information: TastyReferencableInformation = TastyReferencableInformation())
          extends Attribute

      object CaptureChecked {
        given TastyFormat[CaptureChecked] = TastyFormat.forProduct
      }

      case class WithPureFunctions(
        override var information: TastyReferencableInformation = TastyReferencableInformation(),
      ) extends Attribute

      object WithPureFunctions {
        given TastyFormat[WithPureFunctions] = TastyFormat.forProduct
      }

      case class Java(override var information: TastyReferencableInformation = TastyReferencableInformation())
          extends Attribute

      object Java {
        given TastyFormat[Java] = TastyFormat.forProduct
      }

      case class Outline(override var information: TastyReferencableInformation = TastyReferencableInformation())
          extends Attribute

      object Outline {
        given TastyFormat[Outline] = TastyFormat.forProduct
      }

      case class SourceFile(
        path: TastyNameReference,
        override var information: TastyReferencableInformation = TastyReferencableInformation(),
      ) extends Attribute

      object SourceFile {
        given TastyFormat[SourceFile] = TastyFormat.forProduct
      }

      given TastySumType[Attribute] = new TastySumType(
        TastySumType.Variant[Scala2StandardLibrary](DottyTastyFormat.SCALA2STANDARDLIBRARYattr),
        TastySumType.Variant[ExplicitNulls](DottyTastyFormat.EXPLICITNULLSattr),
        TastySumType.Variant[CaptureChecked](DottyTastyFormat.CAPTURECHECKEDattr),
        TastySumType.Variant[WithPureFunctions](DottyTastyFormat.WITHPUREFUNSattr),
        TastySumType.Variant[Java](DottyTastyFormat.JAVAattr),
        TastySumType.Variant[Outline](DottyTastyFormat.OUTLINEattr),
        TastySumType.Variant[SourceFile](DottyTastyFormat.SOURCEFILEattr),
      )

      given TastyFormat[Attribute] = TastyFormat.forSumType
    }

    given TastyFormat[Attributes] =
      TastyFormat.forIterableWithoutLengthPrefixed[Attribute, List[Attribute]].bimap(Attributes(_), _.attributes)
  }
}

sealed trait TastySelector extends TastyReferencable

object TastySelector {
  case class Imported(
    name: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastySelector

  object Imported {
    given TastyFormat[Imported] = TastyFormat.forProduct
  }

  case class Renamed(
    to: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastySelector

  object Renamed {
    given TastyFormat[Renamed] = TastyFormat.forProduct
  }

  case class Bounded(
    `type`: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastySelector

  object Bounded {
    given TastyFormat[Bounded] = TastyFormat.forProduct
  }

  given TastySumType[TastySelector] = new TastySumType(
    TastySumType.Variant[Imported](DottyTastyFormat.IMPORTED),
    TastySumType.Variant[Renamed](DottyTastyFormat.RENAMED),
    TastySumType.Variant[Bounded](DottyTastyFormat.BOUNDED),
  )

  given TastyFormat[TastySelector] = TastyFormat.forSumType
}

case class TastySelf(
  name: TastyNameReference,
  `type`: TastyTypeTree,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastyReferencable

object TastySelf {
  given TastySumType[TastySelf] =
    TastySumType.withSingleVariant(DottyTastyFormat.SELFDEF, TastyFormat.forProduct[TastySelf])

  given TastyFormat[TastySelf] = TastyFormat.forSumType
}

sealed trait TastyStatement extends TastyTopLevelStatement with TastyReferencable

object TastyStatement {
  given TastySumType[TastyStatement] = summon[TastySumType[TastyTerm]]
    .or(summon[TastySumType[TastyValOrDefDefinition]])
    .or(summon[TastySumType[TastyTypeDefinition]])
    .or(
      new TastySumType(
        TastySumType.Variant[TastyImportStatement](DottyTastyFormat.IMPORT),
        TastySumType.Variant[TastyExportStatement](DottyTastyFormat.EXPORT),
      ),
    )

  given TastyFormat[TastyStatement] = TastyFormat.forSumType
}

case class TastyImportStatement(
  qualifier: TastyTerm,
  override var information: TastyReferencableInformation,
  selectors: List[TastySelector],
) extends TastyStatement
    with TastyReferencable

object TastyImportStatement {
  private given TastyFormat[(TastyTerm, TastyReferencableInformation, List[TastySelector])] =
    TastyFormat.forVariadic[(TastyTerm, TastyReferencableInformation), TastySelector, List[TastySelector]]

  given TastyFormat[TastyImportStatement] = TastyFormat.forProduct
}

case class TastyExportStatement(
  qualifier: TastyTerm,
  override var information: TastyReferencableInformation,
  selectors: List[TastySelector],
) extends TastyStatement
    with TastyReferencable

object TastyExportStatement {
  private given TastyFormat[(TastyTerm, TastyReferencableInformation, List[TastySelector])] =
    TastyFormat.forVariadic[(TastyTerm, TastyReferencableInformation), TastySelector, List[TastySelector]]

  given TastyFormat[TastyExportStatement] = TastyFormat.forProduct
}

/**
 * A symbol is ill-defined in the TASTy grammar, but according to Dotty's TASTy unpickler, it can be a definition
 * (`val`, `def`, or `type`), type parameter, parameter, bind pattern, or template:
 * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L592]]
 */
sealed trait TastySymbol extends TastyReferencable

object TastySymbol {
  given TastySumType[TastySymbol] = summon[TastySumType[TastyValOrDefDefinition]]
    .or(summon[TastySumType[TastyTypeDefinition]])
    .or(summon[TastySumType[TastyParameter]])
    .or(summon[TastySumType[TastyTerm.Pattern.Bind]])
    .or(summon[TastySumType[TastyTemplate]])
    /**
     * The compiler is incapable of proving that the union of every subclass of [[TastySymbol]] is equivalent to
     * [[TastySymbol]] itself.
     */
    .or(new TastySumType())

  given TastyFormat[TastySymbol] = TastyFormat.forSumType
}

case class TastyTemplate(
  typeParameters: List[TastyTypeParameter],
  parameters: List[TastyTermParameter],
  parents: List[TastyTerm | TastyTypeTree],
  self: Option[TastySelf],
  statements: List[TastyStatement],
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
) extends TastySymbol

object TastyTemplate {
  private val underlyingTastyFormat = TastyFormat(
    reader =>
      reader.readWithLength(reader.readUnsignedInt().value) { reader =>
        val typeParameters = reader.readWhile(
          !reader.isAtEnd && summon[TastySumType[TastyTypeParameter]].peekIsVariant(reader),
        )(summon[TastyFormat[TastyTypeParameter]].read(reader))

        val parameters = reader.readWhile(
          !reader.isAtEnd && summon[TastySumType[TastyTermParameter]].peekIsVariant(reader),
        )(summon[TastyFormat[TastyTermParameter]].read(reader))

        val parents = reader.readWhile(
          !reader.isAtEnd && summon[TastySumType[TastyTerm | TastyTypeTree]].peekIsVariant(reader),
        )(summon[TastyFormat[TastyTerm | TastyTypeTree]].read(reader))

        val self = Option.when(!reader.isAtEnd && summon[TastySumType[TastySelf]].peekIsVariant(reader))(
          summon[TastyFormat[TastySelf]].read(reader),
        )

        // Why does the specification allow for a `SPLITCLAUSE` here?
        if (reader.peek(_.readByte()) == DottyTastyFormat.SPLITCLAUSE.toByte) {
          reader.readByte()
        }

        val statements = reader.readUntilEnd(summon[TastyFormat[TastyStatement]].read(reader))

        TastyTemplate(typeParameters, parameters, parents, self, statements)
      },
    (writer, template) =>
      writer.writeWithLengthPrefixed { writer =>
        template.typeParameters.foreach(summon[TastyFormat[TastyTypeParameter]].write(writer, _))
        template.parameters.foreach(summon[TastyFormat[TastyTermParameter]].write(writer, _))
        template.parents.foreach(summon[TastyFormat[TastyTerm | TastyTypeTree]].write(writer, _))
        template.self.foreach(summon[TastyFormat[TastySelf]].write(writer, _))
        template.statements.foreach(summon[TastyFormat[TastyStatement]].write(writer, _))
      },
  )

  private given TastySumType[TastyTerm | TastyTypeTree] =
    summon[TastySumType[TastyTerm]].or(summon[TastySumType[TastyTypeTree]])

  private given TastyFormat[TastyTerm | TastyTypeTree] = TastyFormat.forSumType

  given TastySumType[TastyTemplate] =
    TastySumType.withSingleVariant(DottyTastyFormat.TEMPLATE, underlyingTastyFormat)

  given TastyFormat[TastyTemplate] = TastyFormat.forSumType
}

sealed trait TastyTerm extends TastyStatement with TastyReferencable

object TastyTerm {
  case class Identifier(
    name: TastyNameReference,
    `type`: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Identifier {
    given TastyFormat[Identifier] = TastyFormat.forProduct
  }

  case class Select(
    possiblySignedName: TastyNameReference,
    qualified: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Select {
    given TastyFormat[Select] = TastyFormat.forProduct
  }

  case class SelectIn(
    possiblySignedName: TastyNameReference,
    qualified: TastyTerm,
    owner: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object SelectIn {
    given TastyFormat[SelectIn] = TastyFormat.forProduct[SelectIn].withLengthPrefixed
  }

  case class QualifiedThis(
    qualifier: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object QualifiedThis {
    given TastyFormat[QualifiedThis] = TastyFormat.forProduct
  }

  case class New(
    classType: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object New {
    given TastyFormat[New] = TastyFormat.forProduct
  }

  case class Elided(
    expressionType: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Elided {
    given TastyFormat[Elided] = TastyFormat.forProduct
  }

  case class Throw(
    throwable: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Throw {
    given TastyFormat[Throw] = TastyFormat.forProduct
  }

  case class NamedArgument(
    parameterName: TastyNameReference,
    argument: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object NamedArgument {
    given TastyFormat[NamedArgument] = TastyFormat.forProduct
  }

  case class Apply(
    function: TastyTerm,
    override var information: TastyReferencableInformation,
    arguments: List[TastyTerm],
  ) extends TastyTerm

  object Apply {
    private given TastyFormat[(TastyTerm, TastyReferencableInformation, List[TastyTerm])] =
      TastyFormat.forVariadic[(TastyTerm, TastyReferencableInformation), TastyTerm, List[TastyTerm]]

    given TastyFormat[Apply] = TastyFormat.forProduct
  }

  case class ApplySignaturePolymorphic(
    function: TastyTerm,
    methodType: TastyType,
    override var information: TastyReferencableInformation,
    arguments: List[TastyTerm],
  ) extends TastyTerm

  object ApplySignaturePolymorphic {
    private given TastyFormat[(TastyTerm, TastyType, TastyReferencableInformation, List[TastyTerm])] =
      TastyFormat.forVariadic[(TastyTerm, TastyType, TastyReferencableInformation), TastyTerm, List[TastyTerm]]

    given TastyFormat[ApplySignaturePolymorphic] = TastyFormat.forProduct
  }

  case class TypeApply(
    function: TastyTerm,
    override var information: TastyReferencableInformation,
    typeArguments: List[TastyTypeTree],
  ) extends TastyTerm

  object TypeApply {
    private given TastyFormat[(TastyTerm, TastyReferencableInformation, List[TastyTypeTree])] =
      TastyFormat.forVariadic[(TastyTerm, TastyReferencableInformation), TastyTypeTree, List[TastyTypeTree]]

    given TastyFormat[TypeApply] = TastyFormat.forProduct
  }

  case class Super(
    `this`: TastyTerm,
    override var information: TastyReferencableInformation,
    typeArgument: Option[TastyTypeTree],
  ) extends TastyTerm

  object Super {
    private given TastyFormat[(TastyTerm, TastyReferencableInformation, Option[TastyTypeTree])] =
      TastyFormat.forOptional[(TastyTerm, TastyReferencableInformation), TastyTypeTree]

    given TastyFormat[Super] = TastyFormat.forProduct
  }

  case class TypeAscribed(
    expression: TastyTerm,
    ascribedType: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object TypeAscribed {
    given TastyFormat[TypeAscribed] = TastyFormat.forProduct[TypeAscribed].withLengthPrefixed
  }

  case class Assignment(
    leftHandSide: TastyTerm,
    rightHandSide: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Assignment {
    given TastyFormat[Assignment] = TastyFormat.forProduct[Assignment].withLengthPrefixed
  }

  case class Block(
    expression: TastyTerm,
    override var information: TastyReferencableInformation,
    statements: List[TastyStatement],
  ) extends TastyTerm

  object Block {
    private given TastyFormat[(TastyTerm, TastyReferencableInformation, List[TastyStatement])] =
      TastyFormat.forVariadic[(TastyTerm, TastyReferencableInformation), TastyStatement, List[TastyStatement]]

    given TastyFormat[Block] = TastyFormat.forProduct
  }

  case class Inlined(
    expression: TastyTerm,
    call: Option[TastyTypeTree],
    definitions: List[TastyValOrDefDefinition],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Inlined {
    given TastyFormat[Inlined] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val expression = summon[TastyFormat[TastyTerm]].read(reader)
          val call = Option.when(!reader.isAtEnd && summon[TastySumType[TastyTypeTree]].peekIsVariant(reader))(
            summon[TastyFormat[TastyTypeTree]].read(reader),
          )

          val definitions = reader.readUntilEnd(summon[TastyFormat[TastyValOrDefDefinition]].read(reader))

          Inlined(expression, call, definitions)
        },
      (writer, inlined) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyTerm]].write(writer, inlined.expression)

          inlined.call.foreach(summon[TastyFormat[TastyTypeTree]].write(writer, _))
          inlined.definitions.foreach(summon[TastyFormat[TastyValOrDefDefinition]].write(writer, _))
        },
    )
  }

  case class Lambda(
    method: TastyTerm,
    override var information: TastyReferencableInformation,
    targetType: Option[TastyTypeTree],
  ) extends TastyTerm

  object Lambda {
    private given TastyFormat[(TastyTerm, TastyReferencableInformation, Option[TastyTypeTree])] =
      TastyFormat.forOptional[(TastyTerm, TastyReferencableInformation), TastyTypeTree]

    given TastyFormat[Lambda] = TastyFormat.forProduct
  }

  case class If(
    inlined: Boolean,
    condition: TastyTerm,
    thenValue: TastyTerm,
    elseValue: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object If {
    given TastyFormat[If] = TastyFormat(
      reader => {
        reader.readUnsignedInt()

        val inlined = reader.peek(_.readByte()).toInt == DottyTastyFormat.INLINE.toByte

        if (inlined) {
          reader.readByte()
        }

        val condition = summon[TastyFormat[TastyTerm]].read(reader)
        val thenValue = summon[TastyFormat[TastyTerm]].read(reader)
        val elseValue = summon[TastyFormat[TastyTerm]].read(reader)

        If(inlined, condition, thenValue, elseValue)
      },
      (writer, value) =>
        writer.writeWithLengthPrefixed { writer =>
          if (value.inlined) {
            writer.writeByte(DottyTastyFormat.INLINE.toByte)
          }

          summon[TastyFormat[TastyTerm]].write(writer, value.condition)
          summon[TastyFormat[TastyTerm]].write(writer, value.thenValue)
          summon[TastyFormat[TastyTerm]].write(writer, value.elseValue)
        },
    )
  }

  case class Match(
    inline: Boolean,
    scrutinee: Option[TastyTerm],
    cases: List[TastyCaseDefinition],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Match {
    given TastyFormat[Match] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val implicitTag = DottyTastyFormat.IMPLICIT.toByte
          val inlineTag = DottyTastyFormat.INLINE.toByte
          val (inline, scrutinee) = reader.peek(_.readByte()) match {
            case `implicitTag` =>
              reader.readByte()

              (true, None)

            case `inlineTag` =>
              reader.readByte()

              (true, Some(summon[TastyFormat[TastyTerm]].read(reader)))

            case _ => (false, Some(summon[TastyFormat[TastyTerm]].read(reader)))
          }

          val cases = reader.readUntilEnd(summon[TastyFormat[TastyCaseDefinition]].read(reader))

          Match(inline, scrutinee, cases)
        },
      (writer, value) =>
        writer.writeWithLengthPrefixed { writer =>
          (value.inline, value.scrutinee) match {
            case (true, None) => writer.writeByte(DottyTastyFormat.IMPLICIT.toByte)
            case (true, Some(_)) => writer.writeByte(DottyTastyFormat.INLINE.toByte)
            case _ =>
          }

          value.scrutinee.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
          value.cases.foreach(summon[TastyFormat[TastyCaseDefinition]].write(writer, _))
        },
    )
  }

  object Pattern {

    /**
     * [[Bind]] refers to a bound pattern in an ordinary `match` expression or a type `match` (referred to here as an
     * "ordinary bind" and "type bind", respectively). The TASTy grammar differentiates ordinary binds and type binds,
     * but we've merged them into a single class for a couple of reasons:
     *   - It's possible for the pattern of a type bind to be a [[TastyTerm.Identifier]], when it should be a
     *     [[TastyTypeTree.Identifier]]:
     *     [[https://github.com/scalacenter/tasty-query/blob/275ea2d125b16ac74d47d56babfa91bea144f2ad/tasty-query/shared/src/main/scala/tastyquery/reader/tasties/TreeUnpickler.scala#L1645]]
     *     Expressing this in the definition of a type [[Bind]] bind class would complicate it.
     *   - Both ordinary binds and type binds can be [[TastySymbol]]s. Because they begin with the same tag
     *     ([[DottyTastyFormat.BIND]]), differentiating them would be extremely difficult and messy. It's much simpler
     *     to combine them into a single class.
     *
     * @param modifiers
     *   The TASTy grammar doesn't mention this, but [[Bind]] can have modifiers:
     *   [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L1591]]
     */
    case class Bind(
      boundName: TastyNameReference,
      patternType: TastyType,
      pattern: TastyTerm | TastyTypeTree,
      override var information: TastyReferencableInformation,
      modifiers: List[TastyModifier],
    ) extends TastyTerm
        with TastyType
        with TastySymbol

    object Bind {
      private given TastySumType[TastyTerm | TastyTypeTree] =
        summon[TastySumType[TastyTerm]].or(summon[TastySumType[TastyTypeTree]])

      private given TastyFormat[TastyTerm | TastyTypeTree] = TastyFormat.forSumType
      private given TastyFormat[
        (TastyNameReference, TastyType, TastyTerm | TastyTypeTree, TastyReferencableInformation, List[TastyModifier]),
      ] = TastyFormat.forVariadic[
        (TastyNameReference, TastyType, TastyTerm | TastyTypeTree, TastyReferencableInformation),
        TastyModifier,
        List[TastyModifier],
      ]

      /**
       * [[Bind]] gets its own [[TastySumType]] because it's both a [[TastyTerm]] and [[TastySymbol]]. Therefore, its
       * [[TastySumType]] needs to be passed to [[TastySumType.or]].
       */
      given TastySumType[Bind] = TastySumType.withSingleVariant(DottyTastyFormat.BIND, TastyFormat.forProduct[Bind])
      given TastyFormat[Bind] = TastyFormat.forSumType
    }

    case class Alternative(
      override var information: TastyReferencableInformation,
      alternatives: List[TastyTerm],
    ) extends TastyTerm

    object Alternative {
      given TastyFormat[(TastyReferencableInformation, List[TastyTerm])] =
        TastyFormat.forVariadic[Tuple1[TastyReferencableInformation], TastyTerm, List[TastyTerm]]

      given TastyFormat[Alternative] = TastyFormat.forProduct
    }

    case class Unapply(
      function: TastyTerm,
      implicitArguments: List[TastyImplicitArgument],
      patternType: TastyType,
      patterns: List[TastyTerm],
      override var information: TastyReferencableInformation = TastyReferencableInformation(),
    ) extends TastyTerm

    object Unapply {
      given TastyFormat[Unapply] = TastyFormat(
        reader =>
          reader.readWithLength(reader.readUnsignedInt().value) { reader =>
            val function = summon[TastyFormat[TastyTerm]].read(reader)
            val implicitArguments = reader.readWhile(
              !reader.isAtEnd && summon[TastySumType[TastyImplicitArgument]].peekIsVariant(reader),
            )(summon[TastyFormat[TastyImplicitArgument]].read(reader))

            val patternType = summon[TastyFormat[TastyType]].read(reader)
            val patterns = reader.readUntilEnd(summon[TastyFormat[TastyTerm]].read(reader))

            Unapply(function, implicitArguments, patternType, patterns)
          },
        (writer, unapply) =>
          writer.writeWithLengthPrefixed { writer =>
            summon[TastyFormat[TastyTerm]].write(writer, unapply.function)

            unapply.implicitArguments.foreach(summon[TastyFormat[TastyImplicitArgument]].write(writer, _))

            summon[TastyFormat[TastyType]].write(writer, unapply.patternType)

            unapply.patterns.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
          },
      )
    }

    case class QuotePattern(
      body: TastyTerm,
      quotes: TastyTerm,
      patternType: TastyType,
      override var information: TastyReferencableInformation,
      bindings: List[TastyTerm],
    ) extends TastyTerm

    object QuotePattern {
      private given TastyFormat[(TastyTerm, TastyTerm, TastyType, TastyReferencableInformation, List[TastyTerm])] =
        TastyFormat
          .forVariadic[(TastyTerm, TastyTerm, TastyType, TastyReferencableInformation), TastyTerm, List[TastyTerm]]

      given TastyFormat[QuotePattern] = TastyFormat.forProduct
    }
  }

  object PickledQuoteTree {
    case class Explicit(
      typeTree: TastyTypeTree,
      override var information: TastyReferencableInformation = TastyReferencableInformation(),
    ) extends TastyTerm

    object Explicit {
      given TastyFormat[Explicit] = TastyFormat.forProduct
    }

    case class Hole(
      index: UnsignedInt,
      `type`: TastyType,
      override var information: TastyReferencableInformation,
      arguments: List[TastyTerm],
    ) extends TastyTerm

    object Hole {
      private given TastyFormat[(UnsignedInt, TastyType, TastyReferencableInformation, List[TastyTerm])] =
        TastyFormat.forVariadic[(UnsignedInt, TastyType, TastyReferencableInformation), TastyTerm, List[TastyTerm]]

      given TastyFormat[Hole] = TastyFormat.forProduct
    }
  }

  case class Try(
    expression: TastyTerm,
    cases: List[TastyCaseDefinition],
    finalizer: Option[TastyTerm],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Try {
    given TastyFormat[Try] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val expression = summon[TastyFormat[TastyTerm]].read(reader)
          val cases = reader.readWhile(
            !reader.isAtEnd && summon[TastySumType[TastyCaseDefinition]].peekIsVariant(reader),
          )(summon[TastyFormat[TastyCaseDefinition]].read(reader))

          val finalizer = Option.unless(reader.isAtEnd)(summon[TastyFormat[TastyTerm]].read(reader))

          Try(expression, cases, finalizer)
        },
      (writer, value) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyTerm]].write(writer, value.expression)

          value.cases.foreach(summon[TastyFormat[TastyCaseDefinition]].write(writer, _))
          value.finalizer.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
        },
    )
  }

  case class Return(
    method: TastyAstReference[TastyValOrDefDefinition.Def],
    override var information: TastyReferencableInformation,
    expression: Option[TastyTerm],
  ) extends TastyTerm

  object Return {
    private given TastyFormat[
      (TastyAstReference[TastyValOrDefDefinition.Def], TastyReferencableInformation, Option[TastyTerm]),
    ] =
      TastyFormat.forOptional[(TastyAstReference[TastyValOrDefDefinition.Def], TastyReferencableInformation), TastyTerm]

    given TastyFormat[Return] = TastyFormat.forProduct
  }

  case class While(
    condition: TastyTerm,
    body: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object While {
    given TastyFormat[While] = TastyFormat.forProduct[While].withLengthPrefixed
  }

  case class RepeatedArgument(
    elementType: TastyTypeTree,
    override var information: TastyReferencableInformation,
    elements: List[TastyTerm],
  ) extends TastyTerm

  object RepeatedArgument {
    private given TastyFormat[(TastyTypeTree, TastyReferencableInformation, List[TastyTerm])] =
      TastyFormat.forVariadic[(TastyTypeTree, TastyReferencableInformation), TastyTerm, List[TastyTerm]]

    given TastyFormat[RepeatedArgument] = TastyFormat.forProduct
  }

  case class SelectOuter(
    levels: UnsignedInt,
    qualified: TastyTerm,
    `type`: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object SelectOuter {
    given TastyFormat[SelectOuter] = TastyFormat.forProduct[SelectOuter].withLengthPrefixed
  }

  case class Quoted(
    body: TastyTerm,
    bodyType: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Quoted {
    given TastyFormat[Quoted] = TastyFormat.forProduct[Quoted].withLengthPrefixed
  }

  case class Spliced(
    expression: TastyTerm,
    expressionType: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Spliced {
    given TastyFormat[Spliced] = TastyFormat.forProduct[Spliced].withLengthPrefixed
  }

  case class SplicedPattern(
    pattern: TastyTerm,
    patternType: TastyType,
    typeArguments: List[TastyTypeTree],
    arguments: List[TastyTerm],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object SplicedPattern {
    given TastyFormat[SplicedPattern] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val pattern = summon[TastyFormat[TastyTerm]].read(reader)
          val patternType = summon[TastyFormat[TastyType]].read(reader)
          val typeArguments = reader.readWhile(
            !reader.isAtEnd && summon[TastySumType[TastyTypeTree]].peekIsVariant(reader),
          )(summon[TastyFormat[TastyTypeTree]].read(reader))

          val arguments = reader.readUntilEnd(summon[TastyFormat[TastyTerm]].read(reader))

          SplicedPattern(pattern, patternType, typeArguments, arguments)
        },
      (writer, splicedPattern) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyTerm]].write(writer, splicedPattern.pattern)
          summon[TastyFormat[TastyType]].write(writer, splicedPattern.patternType)

          splicedPattern.typeArguments.foreach(summon[TastyFormat[TastyTypeTree]].write(writer, _))
          splicedPattern.arguments.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
        },
    )
  }

  case class Shared(
    term: TastyAstReference[TastyTerm],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTerm

  object Shared {
    given TastyFormat[Shared] = TastyFormat.forProduct
  }

  given TastySumType[TastyTerm] = summon[TastySumType[TastyPath]]
    .or(summon[TastySumType[Pattern.Bind]])
    .or(
      new TastySumType(
        TastySumType.Variant[Identifier](DottyTastyFormat.IDENT),
        TastySumType.Variant[Select](DottyTastyFormat.SELECT),
        TastySumType.Variant[SelectIn](DottyTastyFormat.SELECTin),
        TastySumType.Variant[QualifiedThis](DottyTastyFormat.QUALTHIS),
        TastySumType.Variant[New](DottyTastyFormat.NEW),
        TastySumType.Variant[Elided](DottyTastyFormat.ELIDED),
        TastySumType.Variant[Throw](DottyTastyFormat.THROW),
        TastySumType.Variant[NamedArgument](DottyTastyFormat.NAMEDARG),
        TastySumType.Variant[Apply](DottyTastyFormat.APPLY),
        TastySumType.Variant[ApplySignaturePolymorphic](DottyTastyFormat.APPLYsigpoly),
        TastySumType.Variant[TypeApply](DottyTastyFormat.TYPEAPPLY),
        TastySumType.Variant[Super](DottyTastyFormat.SUPER),
        TastySumType.Variant[TypeAscribed](DottyTastyFormat.TYPED),
        TastySumType.Variant[Assignment](DottyTastyFormat.ASSIGN),
        TastySumType.Variant[Block](DottyTastyFormat.BLOCK),
        TastySumType.Variant[Inlined](DottyTastyFormat.INLINED),
        TastySumType.Variant[Lambda](DottyTastyFormat.LAMBDA),
        TastySumType.Variant[If](DottyTastyFormat.IF),
        TastySumType.Variant[Match](DottyTastyFormat.MATCH),
        TastySumType.Variant[Pattern.Alternative](DottyTastyFormat.ALTERNATIVE),
        TastySumType.Variant[Pattern.Unapply](DottyTastyFormat.UNAPPLY),
        TastySumType.Variant[Pattern.QuotePattern](DottyTastyFormat.QUOTE),
        TastySumType.Variant[PickledQuoteTree.Explicit](DottyTastyFormat.EXPLICITtpt),
        TastySumType.Variant[PickledQuoteTree.Hole](DottyTastyFormat.HOLE),
        TastySumType.Variant[Try](DottyTastyFormat.TRY),
        TastySumType.Variant[Return](DottyTastyFormat.RETURN),
        TastySumType.Variant[While](DottyTastyFormat.WHILE),
        TastySumType.Variant[RepeatedArgument](DottyTastyFormat.REPEATED),
        TastySumType.Variant[SelectOuter](DottyTastyFormat.SELECTouter),
        TastySumType.Variant[Quoted](DottyTastyFormat.QUOTE),
        TastySumType.Variant[Spliced](DottyTastyFormat.SPLICE),
        TastySumType.Variant[SplicedPattern](DottyTastyFormat.SPLICEPATTERN),
        TastySumType.Variant[Shared](DottyTastyFormat.SHAREDterm),
      ),
    )

  given TastyFormat[TastyTerm] = TastyFormat.forSumType
}

sealed trait TastyTopLevelStatement extends TastyReferencable

object TastyTopLevelStatement {
  given TastySumType[TastyTopLevelStatement] =
    new TastySumType(TastySumType.Variant[TastyPackageStatement](DottyTastyFormat.PACKAGE))
      .or(summon[TastySumType[TastyStatement]])

  given TastyFormat[TastyTopLevelStatement] = TastyFormat.forSumType
}

case class TastyPackageStatement(
  path: TastyPath,
  override var information: TastyReferencableInformation,
  topLevelStatements: List[TastyTopLevelStatement],
) extends TastyTopLevelStatement

object TastyPackageStatement {
  private given TastyFormat[(TastyPath, TastyReferencableInformation, List[TastyTopLevelStatement])] = TastyFormat
    .forVariadic[(TastyPath, TastyReferencableInformation), TastyTopLevelStatement, List[TastyTopLevelStatement]]

  given TastyFormat[TastyPackageStatement] = TastyFormat.forProduct
}

sealed trait TastyType extends TastyTypeTree with TastyReferencable

object TastyType {
  case class LocalReference(
    reference: TastyAstReference[TastySymbol],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object LocalReference {
    given TastyFormat[LocalReference] = TastyFormat.forProduct
  }

  case class PrefixedLocalReference(
    reference: TastyAstReference[TastySymbol],
    qualified: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object PrefixedLocalReference {
    given TastyFormat[PrefixedLocalReference] = TastyFormat.forProduct
  }

  case class PackageReference(
    fullyQualifiedName: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object PackageReference {
    given TastyFormat[PackageReference] = TastyFormat.forProduct
  }

  case class NonLocalReference(
    name: TastyNameReference,
    qualified: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object NonLocalReference {
    given TastyFormat[NonLocalReference] = TastyFormat.forProduct
  }

  case class NonLocalReferenceIn(
    name: TastyNameReference,
    qualified: TastyType,
    namespace: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object NonLocalReferenceIn {
    given TastyFormat[NonLocalReferenceIn] = TastyFormat.forProduct[NonLocalReferenceIn].withLengthPrefixed
  }

  case class RecursivelyRefined(
    underlying: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object RecursivelyRefined {
    given TastyFormat[RecursivelyRefined] = TastyFormat.forProduct
  }

  case class Super(
    thisType: TastyType,
    underlying: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Super {
    given TastyFormat[Super] = TastyFormat.forProduct[Super].withLengthPrefixed
  }

  case class Refined(
    refinementName: TastyNameReference,
    underlying: TastyType,
    info: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Refined {
    given TastyFormat[Refined] = TastyFormat.forProduct[Refined].withLengthPrefixed
  }

  case class Applied(
    typeConstructor: TastyType,
    override var information: TastyReferencableInformation,
    arguments: List[TastyType],
  ) extends TastyType

  object Applied {
    private given TastyFormat[(TastyType, TastyReferencableInformation, List[TastyType])] =
      TastyFormat.forVariadic[(TastyType, TastyReferencableInformation), TastyType, List[TastyType]]

    given TastyFormat[Applied] = TastyFormat.forProduct
  }

  case class TypeBounds(
    low: TastyType,
    high: Option[TastyType],
    variances: List[Variance],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object TypeBounds {
    given TastyFormat[TypeBounds] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val low = summon[TastyFormat[TastyType]].read(reader)
          val high = Option.when(!reader.isAtEnd && summon[TastySumType[TastyType]].peekIsVariant(reader))(
            summon[TastyFormat[TastyType]].read(reader),
          )

          val variances = reader.readUntilEnd(summon[TastyFormat[Variance]].read(reader))

          TypeBounds(low, high, variances)
        },
      (writer, typeBounds) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyType]].write(writer, typeBounds.low)

          typeBounds.high.foreach(summon[TastyFormat[TastyType]].write(writer, _))
          typeBounds.variances.foreach(summon[TastyFormat[Variance]].write(writer, _))
        },
    )
  }

  sealed trait Variance extends TastyReferencable

  object Variance {
    case class Invariant(override var information: TastyReferencableInformation = TastyReferencableInformation())
        extends Variance

    object Invariant {
      given TastyFormat[Invariant] = TastyFormat.forProduct
    }

    case class Covariant(override var information: TastyReferencableInformation = TastyReferencableInformation())
        extends Variance

    object Covariant {
      given TastyFormat[Covariant] = TastyFormat.forProduct
    }

    case class Contravariant(override var information: TastyReferencableInformation = TastyReferencableInformation())
        extends Variance

    object Contravariant {
      given TastyFormat[Contravariant] = TastyFormat.forProduct
    }

    given TastySumType[Variance] = new TastySumType(
      TastySumType.Variant[Invariant](DottyTastyFormat.STABLE),
      TastySumType.Variant[Covariant](DottyTastyFormat.COVARIANT),
      TastySumType.Variant[Contravariant](DottyTastyFormat.CONTRAVARIANT),
    )

    given TastyFormat[Variance] = TastyFormat.forSumType
  }

  case class Annotated(
    underlying: TastyType,
    annotation: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Annotated {
    given TastyFormat[Annotated] = TastyFormat.forProduct[Annotated].withLengthPrefixed
  }

  case class And(
    left: TastyType,
    right: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object And {
    given TastyFormat[And] = TastyFormat.forProduct[And].withLengthPrefixed
  }

  case class Or(
    left: TastyType,
    right: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Or {
    given TastyFormat[Or] = TastyFormat.forProduct[Or].withLengthPrefixed
  }

  case class Match(
    upperBound: TastyType,
    scrutinee: TastyType,
    override var information: TastyReferencableInformation,
    cases: List[TastyType],
  ) extends TastyType

  object Match {
    private given TastyFormat[(TastyType, TastyType, TastyReferencableInformation, List[TastyType])] =
      TastyFormat.forVariadic[(TastyType, TastyType, TastyReferencableInformation), TastyType, List[TastyType]]

    given TastyFormat[Match] = TastyFormat.forProduct
  }

  case class MatchCase(
    pattern: TastyType,
    rightHandSide: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object MatchCase {
    given TastyFormat[MatchCase] = TastyFormat.forProduct[MatchCase].withLengthPrefixed
  }

  case class Flexible(
    underlying: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Flexible {
    given TastyFormat[Flexible] = TastyFormat.forProduct[Flexible].withLengthPrefixed
  }

  case class ByName(
    underlying: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object ByName {
    given TastyFormat[ByName] = TastyFormat.forProduct
  }

  /**
   * @param typeOrBounds
   *   According to the TASTy grammar, this should be an AST reference to a type, but it's read in tasty-query as an
   *   actual type:
   *   [[https://github.com/scalacenter/tasty-query/blob/275ea2d125b16ac74d47d56babfa91bea144f2ad/tasty-query/shared/src/main/scala/tastyquery/reader/tasties/TreeUnpickler.scala#L438]]
   */
  case class TypeName(
    typeOrBounds: TastyType,
    name: TastyNameReference,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyReferencable

  object TypeName {
    given TastyFormat[TypeName] = TastyFormat.forProduct
  }

  case class ParameterReference(
    binder: TastyAstReference[TastyType],
    parameterNumber: UnsignedInt,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object ParameterReference {
    given TastyFormat[ParameterReference] = TastyFormat.forProduct[ParameterReference].withLengthPrefixed
  }

  case class PolymorphicMethod(
    result: TastyType,
    override var information: TastyReferencableInformation,
    parameters: List[TypeName],
  ) extends TastyType

  object PolymorphicMethod {
    private given TastyFormat[(TastyType, TastyReferencableInformation, List[TypeName])] =
      TastyFormat.forVariadic[(TastyType, TastyReferencableInformation), TypeName, List[TypeName]]

    given TastyFormat[PolymorphicMethod] = TastyFormat.forProduct
  }

  case class Method(
    result: TastyType,
    parameters: List[TypeName],
    modifiers: List[TastyModifier],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Method {
    given TastyFormat[Method] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val result = summon[TastyFormat[TastyType]].read(reader)
          val parameters = reader.readWhile(
            !reader.isAtEnd && !summon[TastySumType[TastyModifier]].peekIsVariant(reader),
          )(summon[TastyFormat[TypeName]].read(reader))

          val modifiers = reader.readUntilEnd(summon[TastyFormat[TastyModifier]].read(reader))

          Method(result, parameters, modifiers)
        },
      (writer, method) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyType]].write(writer, method.result)

          method.parameters.foreach(summon[TastyFormat[TypeName]].write(writer, _))
          method.modifiers.foreach(summon[TastyFormat[TastyModifier]].write(writer, _))
        },
    )
  }

  case class TypeLambda(
    result: TastyType,
    override var information: TastyReferencableInformation,
    parameters: List[TypeName],
  ) extends TastyType

  object TypeLambda {
    private given TastyFormat[(TastyType, TastyReferencableInformation, List[TypeName])] =
      TastyFormat.forVariadic[(TastyType, TastyReferencableInformation), TypeName, List[TypeName]]

    given TastyFormat[TypeLambda] = TastyFormat.forProduct
  }

  case class Shared(
    `type`: TastyAstReference[TastyType],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object Shared {
    given TastyFormat[Shared] = TastyFormat.forProduct
  }

  /**
   * This isn't formally documented in the TASTy grammar as a type (nor is it clear from reading Dotty's TASTy parser
   * that it's a valid type), but you can find it here:
   * [[https://github.com/scalacenter/tasty-query/blob/275ea2d125b16ac74d47d56babfa91bea144f2ad/tasty-query/shared/src/main/scala/tastyquery/reader/tasties/TreeUnpickler.scala#L980]]
   */
  case class QualifiedThis(
    qualifier: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyType

  object QualifiedThis {
    given TastyFormat[QualifiedThis] = TastyFormat.forProduct
  }

  given TastySumType[TastyType] = summon[TastySumType[TastyPath]]
    .or(summon[TastySumType[TastyTerm.Pattern.Bind]])
    .or(
      new TastySumType(
        TastySumType.Variant[LocalReference](DottyTastyFormat.TYPEREFdirect),
        TastySumType.Variant[PrefixedLocalReference](DottyTastyFormat.TYPEREFsymbol),
        TastySumType.Variant[PackageReference](DottyTastyFormat.TYPEREFpkg),
        TastySumType.Variant[NonLocalReference](DottyTastyFormat.TYPEREF),
        TastySumType.Variant[NonLocalReferenceIn](DottyTastyFormat.TYPEREFin),
        TastySumType.Variant[RecursivelyRefined](DottyTastyFormat.RECtype),
        TastySumType.Variant[Super](DottyTastyFormat.SUPERtype),
        TastySumType.Variant[Refined](DottyTastyFormat.REFINEDtype),
        TastySumType.Variant[Applied](DottyTastyFormat.APPLIEDtype),
        TastySumType.Variant[TypeBounds](DottyTastyFormat.TYPEBOUNDS),
        TastySumType.Variant[Annotated](DottyTastyFormat.ANNOTATEDtype),
        TastySumType.Variant[And](DottyTastyFormat.ANDtype),
        TastySumType.Variant[Or](DottyTastyFormat.ORtype),
        TastySumType.Variant[Match](DottyTastyFormat.MATCHtype),
        TastySumType.Variant[MatchCase](DottyTastyFormat.MATCHCASEtype),
        TastySumType.Variant[Flexible](DottyTastyFormat.FLEXIBLEtype),
        TastySumType.Variant[ByName](DottyTastyFormat.BYNAMEtype),
        TastySumType.Variant[ParameterReference](DottyTastyFormat.PARAMtype),
        TastySumType.Variant[PolymorphicMethod](DottyTastyFormat.POLYtype),
        TastySumType.Variant[Method](DottyTastyFormat.METHODtype),
        TastySumType.Variant[TypeLambda](DottyTastyFormat.TYPELAMBDAtype),
        TastySumType.Variant[Shared](DottyTastyFormat.SHAREDtype),
        TastySumType.Variant[QualifiedThis](DottyTastyFormat.QUALTHIS),
      ),
    )

  given TastyFormat[TastyType] = TastyFormat.forSumType
}

case class TastyTypeDefinition(
  name: TastyNameReference,
  value: TastyTypeTree | TastyTemplate,
  override var information: TastyReferencableInformation = TastyReferencableInformation(),
  modifiers: List[TastyModifier],
) extends TastyStatement
    with TastySymbol

object TastyTypeDefinition {
  private given TastySumType[TastyTypeTree | TastyTemplate] =
    summon[TastySumType[TastyTypeTree]].or(summon[TastySumType[TastyTemplate]])

  private given TastyFormat[TastyTypeTree | TastyTemplate] = TastyFormat.forSumType
  private given TastyFormat[
    (TastyNameReference, TastyTypeTree | TastyTemplate, TastyReferencableInformation, List[TastyModifier]),
  ] = TastyFormat.forVariadic[
    (TastyNameReference, TastyTypeTree | TastyTemplate, TastyReferencableInformation),
    TastyModifier,
    List[TastyModifier],
  ]

  given TastySumType[TastyTypeDefinition] =
    TastySumType.withSingleVariant(DottyTastyFormat.TYPEDEF, TastyFormat.forProduct[TastyTypeDefinition])

  given TastyFormat[TastyTypeDefinition] = TastyFormat.forSumType
}

sealed trait TastyTypeTree extends TastyReferencable

object TastyTypeTree {
  case class Identifier(
    name: TastyNameReference,
    `type`: TastyType,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Identifier {
    given TastyFormat[Identifier] = TastyFormat.forProduct
  }

  /**
   * This isn't formally documented in the TASTy grammar as a type tree, but you can find it here:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L1319]]
   *
   * The difference between this and [[SelectFromType]] is that this selects a type from a term, whereas
   * [[SelectFromType]] selects a field from a type.
   */
  case class SelectFromTerm(
    possiblySignedName: TastyNameReference,
    qualified: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object SelectFromTerm {
    given TastyFormat[SelectFromTerm] = TastyFormat.forProduct
  }

  case class SelectFromType(
    possiblySignedName: TastyNameReference,
    qualified: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object SelectFromType {
    given TastyFormat[SelectFromType] = TastyFormat.forProduct
  }

  case class Singleton(
    reference: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Singleton {
    given TastyFormat[Singleton] = TastyFormat.forProduct
  }

  case class Refined(
    underlying: TastyTypeTree,
    override var information: TastyReferencableInformation,
    refinements: List[TastyStatement],
  ) extends TastyTypeTree

  object Refined {
    private given TastyFormat[(TastyTypeTree, TastyReferencableInformation, List[TastyStatement])] =
      TastyFormat.forVariadic[(TastyTypeTree, TastyReferencableInformation), TastyStatement, List[TastyStatement]]

    given TastyFormat[Refined] = TastyFormat.forProduct
  }

  case class Applied(
    typeConstructor: TastyTypeTree,
    override var information: TastyReferencableInformation,
    typeArguments: List[TastyTypeTree],
  ) extends TastyTypeTree

  object Applied {
    private given TastyFormat[(TastyTypeTree, TastyReferencableInformation, List[TastyTypeTree])] =
      TastyFormat.forVariadic[(TastyTypeTree, TastyReferencableInformation), TastyTypeTree, List[TastyTypeTree]]

    given TastyFormat[Applied] = TastyFormat.forProduct
  }

  case class Lambda(
    typeParameters: List[TastyTypeParameter],
    body: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Lambda {
    given TastyFormat[Lambda] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val typeParameters = reader.readWhile(
            !reader.isAtEnd && summon[TastySumType[TastyTypeParameter]].peekIsVariant(reader),
          )(summon[TastyFormat[TastyTypeParameter]].read(reader))

          val body = summon[TastyFormat[TastyTypeTree]].read(reader)

          Lambda(typeParameters, body)
        },
      (writer, lambda) =>
        writer.writeWithLengthPrefixed { writer =>
          lambda.typeParameters.foreach(summon[TastyFormat[TastyTypeParameter]].write(writer, _))

          summon[TastyFormat[TastyTypeTree]].write(writer, lambda.body)
        },
    )
  }

  /**
   * @param alias
   *   The TASTy grammar doesn't mention this, but [[TypeBounds]] can have a third field:
   *   [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L1654]]
   */
  case class TypeBounds(
    low: TastyTypeTree,
    high: Option[TastyTypeTree],
    alias: Option[TastyTypeTree],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object TypeBounds {
    given TastyFormat[TypeBounds] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val low = summon[TastyFormat[TastyTypeTree]].read(reader)
          val high = Option.unless(reader.isAtEnd)(summon[TastyFormat[TastyTypeTree]].read(reader))
          val alias = Option.unless(reader.isAtEnd)(summon[TastyFormat[TastyTypeTree]].read(reader))

          TypeBounds(low, high, alias)
        },
      (writer, typeBounds) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyTypeTree]].write(writer, typeBounds.low)

          typeBounds.high.foreach(summon[TastyFormat[TastyTypeTree]].write(writer, _))
          typeBounds.alias.foreach(summon[TastyFormat[TastyTypeTree]].write(writer, _))
        },
    )
  }

  case class Annotated(
    underlying: TastyTypeTree,
    annotation: TastyTerm,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Annotated {
    given TastyFormat[Annotated] = TastyFormat.forProduct[Annotated].withLengthPrefixed
  }

  case class Match(
    bound: Option[TastyTypeTree],
    scrutinee: TastyTypeTree,
    cases: List[TastyCaseDefinition],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Match {
    given TastyFormat[Match] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val boundOrScrutinee = summon[TastyFormat[TastyTypeTree]].read(reader)
          val (bound, scrutinee) = if (!reader.isAtEnd && summon[TastySumType[TastyTypeTree]].peekIsVariant(reader)) {
            (Some(boundOrScrutinee), summon[TastyFormat[TastyTypeTree]].read(reader))
          } else {
            (None, boundOrScrutinee)
          }

          val cases = reader.readUntilEnd(summon[TastyFormat[TastyCaseDefinition]].read(reader))

          Match(bound, scrutinee, cases)
        },
      (writer, value) =>
        writer.writeWithLengthPrefixed { writer =>
          value.bound.foreach(summon[TastyFormat[TastyTypeTree]].write(writer, _))

          summon[TastyFormat[TastyTypeTree]].write(writer, value.scrutinee)

          value.cases.foreach(summon[TastyFormat[TastyCaseDefinition]].write(writer, _))
        },
    )
  }

  case class ByName(
    underlying: TastyTypeTree,
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object ByName {
    given TastyFormat[ByName] = TastyFormat.forProduct
  }

  /**
   * This isn't formally documented in the TASTy grammar as a type tree, but you can find it here:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/compiler/src/dotty/tools/dotc/core/tasty/TreeUnpickler.scala#L1691]]
   *
   * It's used to refer to a type tree that's defined elsewhere without duplicating it.
   */
  case class Shared(
    term: TastyAstReference[TastyTypeTree],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyTypeTree

  object Shared {
    given TastyFormat[Shared] = TastyFormat.forProduct
  }

  given TastySumType[TastyTypeTree] = new TastySumType(
    TastySumType.Variant[Identifier](DottyTastyFormat.IDENTtpt),
    TastySumType.Variant[SelectFromTerm](DottyTastyFormat.SELECT),
    TastySumType.Variant[SelectFromType](DottyTastyFormat.SELECTtpt),
    TastySumType.Variant[Singleton](DottyTastyFormat.SINGLETONtpt),
    TastySumType.Variant[Refined](DottyTastyFormat.REFINEDtpt),
    TastySumType.Variant[Applied](DottyTastyFormat.APPLIEDtpt),
    TastySumType.Variant[Lambda](DottyTastyFormat.LAMBDAtpt),
    TastySumType.Variant[TypeBounds](DottyTastyFormat.TYPEBOUNDStpt),
    TastySumType.Variant[Annotated](DottyTastyFormat.ANNOTATEDtpt),
    TastySumType.Variant[Match](DottyTastyFormat.MATCHtpt),
    TastySumType.Variant[ByName](DottyTastyFormat.BYNAMEtpt),
    TastySumType.Variant[Shared](DottyTastyFormat.SHAREDterm),
  ).or(summon[TastySumType[TastyType]])

  given TastyFormat[TastyTypeTree] = TastyFormat.forSumType
}

sealed trait TastyValOrDefDefinition extends TastyStatement with TastySymbol

object TastyValOrDefDefinition {
  case class Val(
    name: TastyNameReference,
    `type`: TastyTypeTree,
    value: Option[TastyTerm],
    modifiers: List[TastyModifier],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyValOrDefDefinition

  object Val {
    given TastyFormat[Val] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val name = summon[TastyFormat[TastyNameReference]].read(reader)
          val `type` = summon[TastyFormat[TastyTypeTree]].read(reader)
          val value = Option.when(!reader.isAtEnd && summon[TastySumType[TastyTerm]].peekIsVariant(reader))(
            summon[TastyFormat[TastyTerm]].read(reader),
          )

          val modifiers = reader.readUntilEnd(summon[TastyFormat[TastyModifier]].read(reader))

          Val(name, `type`, value, modifiers)
        },
      (writer, definition) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyNameReference]].write(writer, definition.name)
          summon[TastyFormat[TastyTypeTree]].write(writer, definition.`type`)

          definition.value.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
          definition.modifiers.foreach(summon[TastyFormat[TastyModifier]].write(writer, _))
        },
    )
  }

  case class Def(
    name: TastyNameReference,
    parameters: List[TastyParameter],
    `type`: TastyTypeTree,
    value: Option[TastyTerm],
    modifiers: List[TastyModifier],
    override var information: TastyReferencableInformation = TastyReferencableInformation(),
  ) extends TastyValOrDefDefinition

  object Def {
    private val underlyingTastyFormat: TastyFormat[Def] = TastyFormat(
      reader =>
        reader.readWithLength(reader.readUnsignedInt().value) { reader =>
          val name = summon[TastyFormat[TastyNameReference]].read(reader)
          val parameters = reader.readWhile(summon[TastySumType[TastyParameter]].peekIsVariant(reader))(
            summon[TastyFormat[TastyParameter]].read(reader),
          )

          val `type` = summon[TastyFormat[TastyTypeTree]].read(reader)
          val value = Option.when(!reader.isAtEnd && summon[TastySumType[TastyTerm]].peekIsVariant(reader))(
            summon[TastyFormat[TastyTerm]].read(reader),
          )

          val modifiers = reader.readUntilEnd(summon[TastyFormat[TastyModifier]].read(reader))

          Def(name, parameters, `type`, value, modifiers)
        },
      (writer, definition) =>
        writer.writeWithLengthPrefixed { writer =>
          summon[TastyFormat[TastyNameReference]].write(writer, definition.name)

          definition.parameters.foreach(summon[TastyFormat[TastyParameter]].write(writer, _))

          summon[TastyFormat[TastyTypeTree]].write(writer, definition.`type`)

          definition.value.foreach(summon[TastyFormat[TastyTerm]].write(writer, _))
          definition.modifiers.foreach(summon[TastyFormat[TastyModifier]].write(writer, _))
        },
    )

    /**
     * [[Def]] gets its own [[TastySumType]] because it's used in [[TastyTerm.Return]] and its tag needs to be included
     * when we're reading or writing a [[TastyTerm.Return]], not just when we're reading or writing a
     * [[TastyValOrDefDefinition]].
     */
    given TastySumType[Def] = TastySumType.withSingleVariant(DottyTastyFormat.DEFDEF, underlyingTastyFormat)
    given TastyFormat[Def] = TastyFormat.forSumType
  }

  given TastySumType[TastyValOrDefDefinition] =
    summon[TastySumType[Def]].or(new TastySumType(TastySumType.Variant[Val](DottyTastyFormat.VALDEF)))

  given TastyFormat[TastyValOrDefDefinition] = TastyFormat.forSumType
}
