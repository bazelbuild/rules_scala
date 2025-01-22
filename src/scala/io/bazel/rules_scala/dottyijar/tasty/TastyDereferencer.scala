package io.bazel.rules_scala.dottyijar.tasty

import io.bazel.rules_scala.dottyijar.tasty.format.{MarkerType, TastyReferencable, TastyReference}
import scala.collection.mutable

class TastyDereferencer(tasty: Tasty) {
  private lazy val referencablesById = tasty.astsSection
    .map { section =>
      mutable.LongMap(
        TastyElement
          .collect(section.payload) { case element: TastyReferencable =>
            element.information.id.map(_.toLong -> element)
          }
          .flatten
          .toSeq*,
      )
    }
    .getOrElse(mutable.LongMap.empty)

  def dereference[A](reference: TastyReference[? <: MarkerType, A]): A =
    referencablesById(reference.referencableId).asInstanceOf[A]

  def isValidReference(reference: TastyReference[? <: MarkerType, ?]): Boolean =
    referencablesById.contains(reference.referencableId)
}
