package io.bazel.rules_scala.dottyijar.tasty

import dotty.tools.dotc.util.Spans.Span
import io.bazel.rules_scala.dottyijar.tasty.format.{MarkerType, TastyReferencableInformation, TastyReference}
import io.bazel.rules_scala.dottyijar.tasty.numeric.{SignedInt, SignedLong, UnsignedInt}
import java.util.UUID
import scala.annotation.nowarn
import scala.collection.Factory
import scala.compiletime.summonAll
import scala.deriving.Mirror

trait TastyElement[A] {

  /**
   * Whether the given value is a node in the TASTy AST, and not an iterable, primitive, or
   * [[TastyReferenceInformation]]. I tried making this `private[tasty]`, but for some reason, Scala inlines it and a
   * [[NoSuchMethodError]] is thrown at runtime in [[TastyElement.forSum]].
   */
  def isNode: Boolean

  def collect[B](value: A)(collector: PartialFunction[Any, B]): Iterable[B]
  def map(value: A)(mapper: [B] => B => TastyElement[B] ?=> B): A
}

object TastyElement
    extends TastyElementIterableGivens
    with TastyElementAlgebraicGivens
    with TastyElementIdentityGivens
    with TastyElementTastyGivens {
  protected def collectChild[A: TastyElement, B](element: A)(collector: PartialFunction[Any, B]): Iterable[B] = {
    val collected = if (summon[TastyElement[A]].isNode && collector.isDefinedAt(element)) {
      Iterable(collector(element))
    } else {
      Iterable.empty
    }

    collected ++ collect(element)(collector)
  }

  protected def mapChild[A: TastyElement](element: A)(mapper: [B] => B => TastyElement[B] ?=> B): A =
    if (summon[TastyElement[A]].isNode) mapper(element) else map(element)(mapper)

  def collect[A: TastyElement, B](value: A)(collector: PartialFunction[Any, B]): Iterable[B] =
    summon[TastyElement[A]].collect(value)(collector)

  def map[A: TastyElement](value: A)(mapper: [B] => B => TastyElement[B] ?=> B): A =
    summon[TastyElement[A]].map(value)(mapper)

  def identity[A](isNode: Boolean): TastyElement[A] = {
    val _isNode = isNode

    new TastyElement[A] {
      override val isNode: Boolean = _isNode
      override def collect[B](value: A)(collector: PartialFunction[Any, B]): Iterable[B] = Iterable.empty
      override def map(value: A)(mapper: [B] => B => TastyElement[B] ?=> B): A = value
    }
  }
}

transparent trait TastyElementIterableGivens { self: TastyElement.type =>
  inline given [A: TastyElement]: TastyElement[Option[A]] with {
    override val isNode: Boolean = false
    override def collect[B](value: Option[A])(collector: PartialFunction[Any, B]): Iterable[B] =
      value.map(collectChild(_)(collector)).getOrElse(Iterable.empty)

    override def map(value: Option[A])(mapper: [B] => B => TastyElement[B] ?=> B): Option[A] =
      value.map(mapChild(_)(mapper))
  }

  inline given [Element: TastyElement, IterableLike[A] <: Iterable[A]](using
    Factory[Element, IterableLike[Element]],
  ): TastyElement[IterableLike[Element]] with {
    override val isNode: Boolean = false
    override def collect[A](value: IterableLike[Element])(collector: PartialFunction[Any, A]): Iterable[A] =
      value.collect(collectChild(_)(collector)).flatten

    override def map(
      value: IterableLike[Element],
    )(mapper: [B] => B => TastyElement[B] ?=> B): IterableLike[Element] =
      summon[Factory[Element, IterableLike[Element]]].fromSpecific(value.map(mapChild(_)(mapper)))
  }
}

transparent trait TastyElementAlgebraicGivens { self: TastyElement.type =>
  given TastyElement[EmptyTuple] = identity(isNode = false)

  inline given tastyReferencableInformationTupleTastyElement[
    A <: Tuple: TastyElement,
  ]: TastyElement[TastyReferencableInformation *: A] with {
    override val isNode: Boolean = false
    override def collect[B](value: TastyReferencableInformation *: A)(collector: PartialFunction[Any, B]): Iterable[B] =
      TastyElement.collect(value.tail)(collector)

    override def map(
      value: TastyReferencableInformation *: A,
    )(mapper: [B] => B => TastyElement[B] ?=> B): TastyReferencableInformation *: A =
      value.head *: TastyElement.map(value.tail)(mapper)
  }

  inline given tupleTastyElement[
    Head: TastyElement,
    Tail <: Tuple: TastyElement,
  ]: TastyElement[Head *: Tail] with {
    override val isNode: Boolean = false
    override def collect[A](value: Head *: Tail)(collector: PartialFunction[Any, A]): Iterable[A] =
      collectChild(value.head)(collector) ++ TastyElement.collect(value.tail)(collector)

    override def map(value: Head *: Tail)(mapper: [A] => A => TastyElement[A] ?=> A): Head *: Tail =
      mapChild(value.head)(mapper) *: TastyElement.map(value.tail)(mapper)
  }

  inline def forProduct[A <: Product](using
    mirror: Mirror.ProductOf[A],
  )(using TastyElement[mirror.MirroredElemTypes]): TastyElement[A] = new TastyElement[A] {
    override val isNode: Boolean = true
    override def collect[B](value: A)(collector: PartialFunction[Any, B]): Iterable[B] =
      TastyElement.collect(Tuple.fromProductTyped(value))(collector)

    override def map(value: A)(mapper: [B] => B => TastyElement[B] ?=> B): A =
      mirror.fromTuple(TastyElement.map(Tuple.fromProductTyped(value))(mapper))
  }: @nowarn("msg=New anonymous class definition will be duplicated at each inline site")

  inline def forSum[Value, Elements <: Tuple](using
    mirror: Mirror.SumOf[Value] { type MirroredElemTypes = Elements },
  ): TastyElement[Value] = new TastyElement[Value] {
    private lazy val tastyElements = summonAll[Tuple.Map[Elements, TastyElement]]
    private def getTastyElement(value: Value): TastyElement[Value] =
      tastyElements.productElement(mirror.ordinal(value)).asInstanceOf[TastyElement[Value]]

    override val isNode: Boolean = true
    override def collect[A](value: Value)(collector: PartialFunction[Any, A]): Iterable[A] =
      getTastyElement(value).collect(value)(collector)

    override def map(value: Value)(mapper: [A] => A => TastyElement[A] ?=> A): Value =
      getTastyElement(value).map(value)(mapper)
  }: @nowarn("msg=New anonymous class definition will be duplicated at each inline site")
}

transparent trait TastyElementIdentityGivens { self: TastyElement.type =>
  given TastyElement[Boolean] = identity(isNode = false)
  given TastyElement[Int] = identity(isNode = false)
  given TastyElement[SignedInt] = identity(isNode = false)
  given TastyElement[SignedLong] = identity(isNode = false)
  given TastyElement[Span] = identity(isNode = false)
  given TastyElement[String] = identity(isNode = false)
  given TastyElement[UnsignedInt] = identity(isNode = false)
  given TastyElement[UUID] = identity(isNode = false)
}

transparent trait TastyElementTastyGivens { self: TastyElement.type =>
  given [RelativeTo <: MarkerType, Value]: TastyElement[TastyReference[RelativeTo, Value]] = identity(isNode = true)

  given TastyElement[Tasty] = forProduct

  given TastyElement[TastyCaseDefinition] = forProduct

  given TastyElement[TastyUnitConstant] = forProduct
  given TastyElement[TastyFalseConstant] = forProduct
  given TastyElement[TastyTrueConstant] = forProduct
  given TastyElement[TastyByteConstant] = forProduct
  given TastyElement[TastyShortConstant] = forProduct
  given TastyElement[TastyCharConstant] = forProduct
  given TastyElement[TastyIntConstant] = forProduct
  given TastyElement[TastyLongConstant] = forProduct
  given TastyElement[TastyFloatConstant] = forProduct
  given TastyElement[TastyDoubleConstant] = forProduct
  given TastyElement[TastyStringConstant] = forProduct
  given TastyElement[TastyNullConstant] = forProduct
  given TastyElement[TastyClassConstant] = forProduct
  given TastyElement[TastyConstant] = forSum

  given TastyElement[TastyImplicitArgument] = forProduct

  given TastyElement[TastyModifier.Private] = forProduct
  given TastyElement[TastyModifier.Protected] = forProduct
  given TastyElement[TastyModifier.PrivateQualified] = forProduct
  given TastyElement[TastyModifier.ProtectedQualified] = forProduct
  given TastyElement[TastyModifier.Abstract] = forProduct
  given TastyElement[TastyModifier.Final] = forProduct
  given TastyElement[TastyModifier.Sealed] = forProduct
  given TastyElement[TastyModifier.Case] = forProduct
  given TastyElement[TastyModifier.Implicit] = forProduct
  given TastyElement[TastyModifier.Given] = forProduct
  given TastyElement[TastyModifier.Erased] = forProduct
  given TastyElement[TastyModifier.Lazy] = forProduct
  given TastyElement[TastyModifier.Override] = forProduct
  given TastyElement[TastyModifier.Opaque] = forProduct
  given TastyElement[TastyModifier.Inline] = forProduct
  given TastyElement[TastyModifier.Macro] = forProduct
  given TastyElement[TastyModifier.InlineProxy] = forProduct
  given TastyElement[TastyModifier.Static] = forProduct
  given TastyElement[TastyModifier.Object] = forProduct
  given TastyElement[TastyModifier.Trait] = forProduct
  given TastyElement[TastyModifier.Enum] = forProduct
  given TastyElement[TastyModifier.Local] = forProduct
  given TastyElement[TastyModifier.Synthetic] = forProduct
  given TastyElement[TastyModifier.Artifact] = forProduct
  given TastyElement[TastyModifier.Mutable] = forProduct
  given TastyElement[TastyModifier.FieldAccessor] = forProduct
  given TastyElement[TastyModifier.CaseAccessor] = forProduct
  given tastyModifierCovariantTastyElement: TastyElement[TastyModifier.Covariant] = forProduct
  given tastyModifierContravariantTastyElement: TastyElement[TastyModifier.Contravariant] = forProduct
  given TastyElement[TastyModifier.HasDefault] = forProduct
  given TastyElement[TastyModifier.Stable] = forProduct
  given TastyElement[TastyModifier.Extension] = forProduct
  given TastyElement[TastyModifier.ParameterSetter] = forProduct
  given TastyElement[TastyModifier.ParameterAlias] = forProduct
  given TastyElement[TastyModifier.Exported] = forProduct
  given TastyElement[TastyModifier.Open] = forProduct
  given TastyElement[TastyModifier.Invisible] = forProduct
  given TastyElement[TastyModifier.Tracked] = forProduct
  given TastyElement[TastyModifier.Annotation] = forProduct
  given TastyElement[TastyModifier.Transparent] = forProduct
  given TastyElement[TastyModifier.Infix] = forProduct
  given TastyElement[TastyModifier] = forSum

  given TastyElement[TastyName.Simple] = forProduct
  given TastyElement[TastyName.Qualified] = forProduct
  given TastyElement[TastyName.Expanded] = forProduct
  given TastyElement[TastyName.ExpandPrefix] = forProduct
  given TastyElement[TastyName.Unique] = forProduct
  given TastyElement[TastyName.DefaultGetter] = forProduct
  given TastyElement[TastyName.SuperAccessor] = forProduct
  given TastyElement[TastyName.InlineAccessor] = forProduct
  given TastyElement[TastyName.ObjectClass] = forProduct
  given TastyElement[TastyName.BodyRetainer] = forProduct
  given TastyElement[TastyName.Signed] = forProduct
  given TastyElement[TastyName.TargetSigned] = forProduct
  given TastyElement[TastyName] = forSum

  given TastyElement[TastyNameReference] = forProduct

  given TastyElement[TastyNameTable] = forProduct

  given TastyElement[TastyTypeParameter] = forProduct
  given TastyElement[TastyTermParameter] = forProduct
  given TastyElement[TastyParameter.EmptyClause] = forProduct
  given TastyElement[TastyParameter.SplitClause] = forProduct
  given TastyElement[TastyParameter] = forSum

  given TastyElement[TastyParameterSignature.TypeParameterSectionLength] = forProduct
  given TastyElement[TastyParameterSignature.TermParameter] = forProduct
  given TastyElement[TastyParameterSignature] = forSum

  given tastyPathLocalReferenceTastyElement: TastyElement[TastyPath.LocalReference] = forProduct
  given tastyPathPrefixedLocalReferenceTastyElement: TastyElement[TastyPath.PrefixedLocalReference] = forProduct
  given tastyPathPackageReferenceTastyElement: TastyElement[TastyPath.PackageReference] = forProduct
  given tastyPathNonLocalReferenceTastyElement: TastyElement[TastyPath.NonLocalReference] = forProduct
  given tastyPathNonLocalReferenceInTastyElement: TastyElement[TastyPath.NonLocalReferenceIn] = forProduct
  given TastyElement[TastyPath.This] = forProduct
  given TastyElement[TastyPath.RecursivelyRefinedThis] = forProduct
  given tastyPathSharedTastyElement: TastyElement[TastyPath.Shared] = forProduct
  given TastyElement[TastyPath] = forSum

  given [A <: TastySectionPayload: TastyElement]: TastyElement[TastySection[A]] = forProduct

  given TastyElement[TastySectionPayload.Asts] = forProduct
  given TastyElement[TastySectionPayload.Positions.Delta] = forProduct
  given TastyElement[TastySectionPayload.Positions.Source] = forProduct
  given TastyElement[TastySectionPayload.Positions.LineSizes] = forProduct
  given TastyElement[TastySectionPayload.Positions] = {
    given TastyElement[TastySectionPayload.Positions.Delta | TastySectionPayload.Positions.Source] with {
      override val isNode: Boolean = true
      override def collect[A](
        value: TastySectionPayload.Positions.Delta | TastySectionPayload.Positions.Source,
      )(collector: PartialFunction[Any, A]): Iterable[A] = value match {
        case delta: TastySectionPayload.Positions.Delta => TastyElement.collect(delta)(collector)
        case source: TastySectionPayload.Positions.Source => TastyElement.collect(source)(collector)
      }

      override def map(value: TastySectionPayload.Positions.Delta | TastySectionPayload.Positions.Source)(
        mapper: [A] => A => TastyElement[A] ?=> A,
      ): TastySectionPayload.Positions.Delta | TastySectionPayload.Positions.Source =
        value match {
          case delta: TastySectionPayload.Positions.Delta => TastyElement.map(delta)(mapper)
          case source: TastySectionPayload.Positions.Source => TastyElement.map(source)(mapper)
        }
    }

    forProduct
  }

  given TastyElement[TastySectionPayload.Comments.Comment] = forProduct
  given TastyElement[TastySectionPayload.Comments] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.Scala2StandardLibrary] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.ExplicitNulls] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.CaptureChecked] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.WithPureFunctions] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.Java] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.Outline] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute.SourceFile] = forProduct
  given TastyElement[TastySectionPayload.Attributes.Attribute] = forSum
  given TastyElement[TastySectionPayload.Attributes] = forProduct

  given TastyElement[TastySelector.Imported] = forProduct
  given TastyElement[TastySelector.Renamed] = forProduct
  given TastyElement[TastySelector.Bounded] = forProduct
  given TastyElement[TastySelector] = forSum

  given TastyElement[TastySelf] = forProduct

  given TastyElement[TastyImportStatement] = forProduct
  given TastyElement[TastyExportStatement] = forProduct
  given TastyElement[TastyStatement] = forSum

  given TastyElement[TastyTemplate] = {
    given TastyElement[TastyTerm | TastyTypeTree] with {
      override val isNode: Boolean = true
      override def collect[A](value: TastyTerm | TastyTypeTree)(collector: PartialFunction[Any, A]): Iterable[A] =
        value match {
          case term: TastyTerm => TastyElement.collect(term)(collector)
          case typeTree: TastyTypeTree => TastyElement.collect(typeTree)(collector)
        }

      override def map(
        value: TastyTerm | TastyTypeTree,
      )(mapper: [A] => A => TastyElement[A] ?=> A): TastyTerm | TastyTypeTree = value match {
        case term: TastyTerm => TastyElement.map(term)(mapper)
        case typeTree: TastyTypeTree => TastyElement.map(typeTree)(mapper)
      }
    }

    forProduct
  }

  given tastyTermIdentifierTastyElement: TastyElement[TastyTerm.Identifier] = forProduct
  given TastyElement[TastyTerm.Select] = forProduct
  given TastyElement[TastyTerm.SelectIn] = forProduct
  given tastyTermQualifiedThisTastyElement: TastyElement[TastyTerm.QualifiedThis] = forProduct
  given TastyElement[TastyTerm.New] = forProduct
  given TastyElement[TastyTerm.Elided] = forProduct
  given TastyElement[TastyTerm.Throw] = forProduct
  given TastyElement[TastyTerm.NamedArgument] = forProduct
  given TastyElement[TastyTerm.Apply] = forProduct
  given TastyElement[TastyTerm.ApplySignaturePolymorphic] = forProduct
  given TastyElement[TastyTerm.TypeApply] = forProduct
  given tastyTermSuperTastyElement: TastyElement[TastyTerm.Super] = forProduct
  given TastyElement[TastyTerm.TypeAscribed] = forProduct
  given TastyElement[TastyTerm.Assignment] = forProduct
  given TastyElement[TastyTerm.Block] = forProduct
  given TastyElement[TastyTerm.Inlined] = forProduct
  given tastyTypeLambdaTastyElement: TastyElement[TastyTerm.Lambda] = forProduct
  given TastyElement[TastyTerm.If] = forProduct
  given tastyTermMatchTastyElement: TastyElement[TastyTerm.Match] = forProduct
  given TastyElement[TastyTerm.Pattern.Bind] = {
    given TastyElement[TastyTerm | TastyTypeTree] with {
      override val isNode: Boolean = true
      override def collect[A](value: TastyTerm | TastyTypeTree)(collector: PartialFunction[Any, A]): Iterable[A] =
        value match {
          case term: TastyTerm => TastyElement.collect(term)(collector)
          case typeTree: TastyTypeTree => TastyElement.collect(typeTree)(collector)
        }

      override def map(
        value: TastyTerm | TastyTypeTree,
      )(mapper: [A] => A => TastyElement[A] ?=> A): TastyTerm | TastyTypeTree = value match {
        case term: TastyTerm => TastyElement.map(term)(mapper)
        case typeTree: TastyTypeTree => TastyElement.map(typeTree)(mapper)
      }
    }

    forProduct
  }

  given TastyElement[TastyTerm.Pattern.Alternative] = forProduct
  given TastyElement[TastyTerm.Pattern.Unapply] = forProduct
  given TastyElement[TastyTerm.Pattern.QuotePattern] = forProduct
  given TastyElement[TastyTerm.PickledQuoteTree.Explicit] = forProduct
  given TastyElement[TastyTerm.PickledQuoteTree.Hole] = forProduct
  given TastyElement[TastyTerm.Try] = forProduct
  given TastyElement[TastyTerm.Return] = forProduct
  given TastyElement[TastyTerm.While] = forProduct
  given TastyElement[TastyTerm.RepeatedArgument] = forProduct
  given TastyElement[TastyTerm.SelectOuter] = forProduct
  given TastyElement[TastyTerm.Quoted] = forProduct
  given TastyElement[TastyTerm.Spliced] = forProduct
  given TastyElement[TastyTerm.SplicedPattern] = forProduct
  given tastyTermSharedTastyElement: TastyElement[TastyTerm.Shared] = forProduct
  given TastyElement[TastyTerm] = forSum

  given TastyElement[TastyPackageStatement] = forProduct
  given TastyElement[TastyTopLevelStatement] = forSum

  given tastyTypeLocalReferenceTastyElement: TastyElement[TastyType.LocalReference] = forProduct
  given tastyTypePrefixedLocalReferenceTastyElement: TastyElement[TastyType.PrefixedLocalReference] = forProduct
  given tastyTypePackageReferenceTastyElement: TastyElement[TastyType.PackageReference] = forProduct
  given tastyTypeNonLocalReferenceTastyElement: TastyElement[TastyType.NonLocalReference] = forProduct
  given tastyTypeNonLocalReferenceInTastyElement: TastyElement[TastyType.NonLocalReferenceIn] = forProduct
  given TastyElement[TastyType.RecursivelyRefined] = forProduct
  given tastyTypeSuperTastyElement: TastyElement[TastyType.Super] = forProduct
  given tastyTypeRefinedTastyElement: TastyElement[TastyType.Refined] = forProduct
  given tastyTypeAppliedTastyElement: TastyElement[TastyType.Applied] = forProduct
  given tastyTypeTypeBoundsTastyElement: TastyElement[TastyType.TypeBounds] = forProduct
  given TastyElement[TastyType.Variance.Invariant] = forProduct
  given tastyTypeVarianceCovariantTastyElement: TastyElement[TastyType.Variance.Covariant] = forProduct
  given tastyTypeVarianceContravariantTastyElement: TastyElement[TastyType.Variance.Contravariant] = forProduct
  given TastyElement[TastyType.Variance] = forSum
  given tastyTypeAnnotatedTastyElement: TastyElement[TastyType.Annotated] = forProduct
  given TastyElement[TastyType.And] = forProduct
  given TastyElement[TastyType.Or] = forProduct
  given tastyTypeMatchTastyElement: TastyElement[TastyType.Match] = forProduct
  given TastyElement[TastyType.MatchCase] = forProduct
  given TastyElement[TastyType.Flexible] = forProduct
  given tastyTypeByNameTastyElement: TastyElement[TastyType.ByName] = forProduct
  given TastyElement[TastyType.TypeName] = forProduct
  given TastyElement[TastyType.ParameterReference] = forProduct
  given TastyElement[TastyType.PolymorphicMethod] = forProduct
  given TastyElement[TastyType.Method] = forProduct
  given TastyElement[TastyType.TypeLambda] = forProduct
  given tastyTypeSharedTastyElement: TastyElement[TastyType.Shared] = forProduct
  given tastyTypeQualifiedThisTastyElement: TastyElement[TastyType.QualifiedThis] = forProduct
  given TastyElement[TastyType] = forSum

  given TastyElement[TastyTypeDefinition] = {
    given TastyElement[TastyTypeTree | TastyTemplate] with {
      override val isNode: Boolean = true
      override def collect[A](value: TastyTypeTree | TastyTemplate)(collector: PartialFunction[Any, A]): Iterable[A] =
        value match {
          case typeTree: TastyTypeTree => TastyElement.collect(typeTree)(collector)
          case template: TastyTemplate => TastyElement.collect(template)(collector)
        }

      override def map(
        value: TastyTypeTree | TastyTemplate,
      )(mapper: [A] => A => TastyElement[A] ?=> A): TastyTypeTree | TastyTemplate = value match {
        case typeTree: TastyTypeTree => TastyElement.map(typeTree)(mapper)
        case template: TastyTemplate => TastyElement.map(template)(mapper)
      }
    }

    forProduct
  }

  given tastyTypeTreeIdentifierTastyElement: TastyElement[TastyTypeTree.Identifier] = forProduct
  given TastyElement[TastyTypeTree.SelectFromTerm] = forProduct
  given TastyElement[TastyTypeTree.SelectFromType] = forProduct
  given TastyElement[TastyTypeTree.Singleton] = forProduct
  given tastyTypeTreeRefinedTastyElement: TastyElement[TastyTypeTree.Refined] = forProduct
  given tastyTypeTreeAppliedTastyElement: TastyElement[TastyTypeTree.Applied] = forProduct
  given tastyTypeTreeLambdaTastyElement: TastyElement[TastyTypeTree.Lambda] = forProduct
  given tastyTypeTreeTypeBoundsTastyElement: TastyElement[TastyTypeTree.TypeBounds] = forProduct
  given tastyTypeTreeAnnotatedTastyElement: TastyElement[TastyTypeTree.Annotated] = forProduct
  given tastyTypeTreeMatchTastyElement: TastyElement[TastyTypeTree.Match] = forProduct
  given tastyTypeTreeByNameTastyElement: TastyElement[TastyTypeTree.ByName] = forProduct
  given tastyTypeTreeSharedTastyElement: TastyElement[TastyTypeTree.Shared] = forProduct
  given TastyElement[TastyTypeTree] = forSum

  given TastyElement[TastyValOrDefDefinition.Val] = forProduct
  given TastyElement[TastyValOrDefDefinition.Def] = forProduct
  given TastyElement[TastyValOrDefDefinition] = forSum
}
