package scalarules.test.scala_import.nl

import org.specs2.mutable.SpecificationWithJUnit

class ScalaImportNeverLinkTest extends SpecificationWithJUnit {
  "neverlinked scala_import" should {
    "not be available in runtime" in {
      //ScalaImportNeverLink class is packaged in scala_import_never_link.jar. Since the scala_import target
      //is marked as "neverlink" - this test class/target will be built successfully but will fail on runtime with
      //NoClassDefFoundError (neverlink targets are not available on runtime only on build/compile)
      createScalaImportNeverLink() must throwA[NoClassDefFoundError]("scalarules/test/scala_import/nl/ScalaImportNeverLink")
    }
  }

  private def createScalaImportNeverLink() = new ScalaImportNeverLink()

}
