package scalarules.test.scala_import

import java.util.jar.JarFile

import com.google.common.cache.Cache
import org.apache.commons.lang3.ArrayUtils
import org.specs2.mutable.SpecWithJUnit

import scala.reflect.{ClassTag, _}

class ScalaImportExposesJarsTest extends SpecWithJUnit {

  "scala_import" should {
    "enable using the jars it exposes" in {
      println(classOf[Cache[String, String]])
      println(classOf[ArrayUtils])
      success
    }

    "stamps jars with a target label" in {
      val targetLabel = "//test/src/main/scala/scalarules/test/scala_import:guava_and_commons_lang"
      findTargetLabel[Cache[String, String]] must beSome(targetLabel)
      findTargetLabel[ArrayUtils] must beSome(targetLabel)
    }
  }

  def findTargetLabel[T: ClassTag]: Option[String] = {
    val file = classTag[T].runtimeClass.getProtectionDomain.getCodeSource.getLocation.getFile
    val jar = new JarFile(file)
    val label = jar.getManifest.getMainAttributes.getValue("Target-Label")
    jar.close()
    Some(label)
  }

}
