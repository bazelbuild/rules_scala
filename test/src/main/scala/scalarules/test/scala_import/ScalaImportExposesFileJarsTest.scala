package scalarules.test.scala_import

import  scalarules.test.scala_import.generic.Generic

import org.specs2.mutable.SpecificationWithJUnit

class ScalaImportExposesJarsTest extends SpecificationWithJUnit {

  "scala_import" >> {
    "enable importing jars from files" in {
      assert(Generic.foo == "bar")
      success
    }
  }

}
