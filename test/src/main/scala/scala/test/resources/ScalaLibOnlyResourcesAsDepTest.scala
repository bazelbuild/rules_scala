package scala.test.resources

import org.specs2.mutable.SpecWithJUnit

class ScalaLibOnlyResourcesAsDepTest extends SpecWithJUnit {

  "Scala library depending on resources from resource-only jar" should {
    "allow to load resources" >> {
      get("/resource.txt") must beEqualTo("I am a text resource!")
    }
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}

