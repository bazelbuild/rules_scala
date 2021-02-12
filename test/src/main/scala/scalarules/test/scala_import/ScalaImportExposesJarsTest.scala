package scalarules.test.scala_import

import com.google.common.cache.Cache
import org.apache.commons.lang3.ArrayUtils
import org.specs2.mutable.SpecWithJUnit

class ScalaImportExposesJarsTest extends SpecWithJUnit {
  val targetLabel = "//test/src/main/scala/scalarules/test/scala_import:guava_and_commons_lang"

  "scala_import" should {
    "enable using the jars it exposes" in {
      println(classOf[Cache[String, String]])
      println(classOf[ArrayUtils])
      success
    }
  }

}
