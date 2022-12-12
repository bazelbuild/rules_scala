package scalarules.test.duplicated

import org.scalatest.funsuite._

class ScalaLibResourcesDuplicatedTest extends AnyFunSuite {

  test("Scala library depends on resource + deps that contains same name resources, have higher priority on this target's resource.") {
    assert(get("/resource.txt") === "I am a text resource from child!\n")
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
