package scalarules.test.scala_import.nl

import org.specs2.mutable.SpecificationWithJUnit
import scala.util.control.NonFatal

class ScalaImportNeverLinkTest extends SpecificationWithJUnit {
  "neverlinked scala_import" should {
    "not be available in runtime" in {
      //ScalaImportNeverLink class is packaged in scala_import_never_link.jar. Since the scala_import target
      //is marked as "neverlink" - this test class/target will be built successfully but will fail on runtime with
      //NoClassDefFoundError (neverlink targets are not available on runtime only on build/compile)
      try {
        createScalaImportNeverLink()
        failure("shouldn't have been able to create an instance of ScalaImportNeverLink")
      } catch {
        case e : NoClassDefFoundError => success
        case NonFatal(e) => failure("expected NoClassDefFoundError but got $e")
      }
    }
  }

  private def createScalaImportNeverLink() = new ScalaImportNeverLink()

}
