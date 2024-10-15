package scalarules.test.resources

import org.scalatest.funsuite._

class ScalaLibResourcesFromExternalScalaTest extends AnyFunSuite {

  test("Scala library depending on resources from external resource-only jar should allow to load resources") {
    val expectedString = String.format("A resource%n"); //Using platform dependent newline (%n)
    assert(get("/resource.txt") === expectedString)
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
