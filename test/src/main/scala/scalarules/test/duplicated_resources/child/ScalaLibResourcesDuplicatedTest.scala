package scalarules.test.duplicated

import org.scalatest.funsuite._

class ScalaLibResourcesDuplicatedTest extends AnyFunSuite {

  test("Scala library depending on resources from external resource-only jar should allow to load resources") {
    assert(get("/resource.txt") === "I am a text resource from child!\n")
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
