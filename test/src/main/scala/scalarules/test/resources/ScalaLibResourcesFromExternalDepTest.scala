package scalarules.test.resources

import org.specs2.mutable.SpecWithJUnit

class ScalaLibResourcesFromExternalDepTest extends SpecWithJUnit {

  "Scala library depending on resources from external resource-only jar" >> {
    "allow to load resources" >> {

      val expectedString = String.format("A resource%n"); //Using platform dependent newline (%n)
      get("/resource.txt") must beEqualTo(expectedString)
  
    }
  }

  private def get(s: String): String ={
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString
  }
}
