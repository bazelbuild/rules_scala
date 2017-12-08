package scala.test.resources

import org.specs2.mutable.SpecWithJUnit

class ScalaLibOnlyResourcesTest extends SpecWithJUnit {

  "Scala library with no srcs and only resources" should {
    "allow to load resources" >> {
      get("/resource.txt") must beEqualTo("I am a text resource!")
    }
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}
