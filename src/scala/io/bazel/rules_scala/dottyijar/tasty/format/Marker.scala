package io.bazel.rules_scala.dottyijar.tasty.format

private case class Marker(position: Int, markerType: MarkerType)

sealed abstract class MarkerType

object MarkerType {
  case object AstSection extends MarkerType
}

class MarkerNotSetException(markerType: MarkerType) extends Exception(s"A marker of type $markerType hasn't been set.")
