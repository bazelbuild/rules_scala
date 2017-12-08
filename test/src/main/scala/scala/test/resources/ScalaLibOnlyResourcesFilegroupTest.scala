package scala.test.resources

import org.specs2.mutable.SpecWithJUnit

class ScalaLibOnlyResourcesFilegroupTest extends SpecWithJUnit {

  "Scala library with no srcs and only filegroup resources" should {
    "allow to load resources" >> {
      get("/resource.txt") must beEqualTo("I am a text resource!")
      get("/subdir/resource.txt") must beEqualTo("I am a text resource in a subdir!")
    }
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}

