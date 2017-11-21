package scala.test.scala_import

import com.google.common.cache.Cache
import org.apache.commons.lang3.ArrayUtils
import org.specs2.mutable.SpecificationWithJUnit

class ScalaImportExposesJarsTest extends SpecificationWithJUnit {

  "scala_import" should {
    "enable using the jars it exposes" in {
      println(classOf[Cache[String, String]])
      println(classOf[ArrayUtils])
      success
    }
  }

}
