package scalarules.test.scala_import

import org.specs2.mutable.SpecificationWithJUnit

class ScalaImportPropagatesRuntimeDepsTest extends SpecificationWithJUnit {

  "scala_import" >> {
    "propagate runtime deps" in {
      println(Class.forName("com.google.common.cache.Cache"))
      println(Class.forName("org.apache.commons.lang3.ArrayUtils"))
      println(Class.forName("cats.Applicative"))
      success
    }
  }

}
