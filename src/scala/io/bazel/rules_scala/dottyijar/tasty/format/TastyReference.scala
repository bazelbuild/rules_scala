package io.bazel.rules_scala.dottyijar.tasty.format

import izumi.reflect.Tag

/**
 * References another value in the TASTy file. In their serialized form, [[TastyReference]]s are represented as an
 * offset from some marker in the TASTy file. In reality, the only marker is the AST section payload, but I wanted to
 * make [[TastyReference]] indifferent to the marker type to enforce a separation between the infrastructure for reading
 * to and writing from TASTy files ([[TastyReference]], [[TastyFormat]], [[TastyReader]], and [[TastyWriter]]) and the
 * TASTy types.
 *
 * In their deserialized form, [[TastyReference]]s are assigned IDs that uniquely identify the value they're
 * referencing. These values should extend [[TastyReferencable]], which has an `information` field containing this ID.
 * We opted to represent references in this way because it makes it far easier to update the values they reference. If,
 * instead, we stored the address to which they point, we'd have to update those addresses whenever they change, which
 * is very difficult to do in automated fashion.
 */
case class TastyReference[RelativeTo <: MarkerType, Value](relativeTo: RelativeTo, referencableId: Int)

object TastyReference {

  /**
   * [[Value]] must have a [[TastySumType]] because values that have [[TastySumType]]s are the only values whose
   * positions we record during writing. See the comment in the implementation of [[TastyFormat.forSumType]] to
   * understand why.
   */
  given [RelativeTo <: MarkerType: ValueOf: Tag, Value: Tag](using
    => TastySumType[Value],
  ): TastyFormat[TastyReference[RelativeTo, Value]] = TastyFormat(
    reader => reader.readReference(summon[ValueOf[RelativeTo]].value),
    (writer, reference) => writer.writeReference(reference),
  )
}

type TastyAstReference[A] = TastyReference[MarkerType.AstSection.type, A]
