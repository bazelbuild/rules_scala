package scalarules.test.duplicated

import org.scalatest.funsuite._

class ScalaLibResourcesDuplicatedTest extends AnyFunSuite {

  test("Scala library depends on resource + deps that contains same name resources, have higher priority on this target's resource.") {
    //Using platform dependent newline (%n)
    assert(get("/resource.txt") === String.format("I am a text resource from child!%n"))
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
