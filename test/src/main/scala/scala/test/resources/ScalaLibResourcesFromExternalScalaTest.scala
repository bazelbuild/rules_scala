package scala.test.resources

import org.scalatest.FunSuite

class ScalaLibResourcesFromExternalScalaTest extends FunSuite {

  test("Scala library depending on resources from external resource-only jar should allow to load resources") {
      assert(get("/external/test_new_local_repo/resource.txt") === "A resource\n")
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
