package test_expect_failure.scala_import

import com.google.common.cache.Cache
import org.apache.commons.lang3.ArrayUtils
import org.specs2.mutable.SpecificationWithJUnit

class ScalaImportPropagatesCompileDepsTest extends SpecificationWithJUnit {

  "scala_import" should {
    "propagate runtime deps" in {
      println(classOf[Cache[String, String]])
      println(classOf[ArrayUtils])
      println(classOf[cats.Applicative[Any]])
      success
    }
  }

}
