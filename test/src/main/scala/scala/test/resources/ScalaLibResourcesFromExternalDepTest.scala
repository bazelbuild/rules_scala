package scala.test.resources

import org.specs2.mutable.SpecWithJUnit

class ScalaLibResourcesFromExternalDepTest extends SpecWithJUnit {

  "Scala library depending on resources from external resource-only jar" should {
    "allow to load resources" >> {
      get("/external/test_new_local_repo/resource.txt") must beEqualTo("A resource\n")
    }
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
