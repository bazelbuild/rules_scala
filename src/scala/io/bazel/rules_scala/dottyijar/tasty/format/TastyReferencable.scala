package io.bazel.rules_scala.dottyijar.tasty.format

trait TastyReferencable {
  def information: TastyReferencableInformation
  def information_=(newInformation: TastyReferencableInformation): Unit
}

case class TastyReferencableInformation(id: Option[Int] = None)

object TastyReferencableInformation {
  given TastyFormat[TastyReferencableInformation] = new TastyFormat[TastyReferencableInformation] {
    def read(reader: TastyReader): TastyReferencableInformation = TastyReferencableInformation()
    def write(writer: TastyWriter, value: TastyReferencableInformation): Unit = {}
  }
}
