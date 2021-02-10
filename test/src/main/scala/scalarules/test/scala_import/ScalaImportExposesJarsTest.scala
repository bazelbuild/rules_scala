package scalarules.test.scala_import

import java.util.jar
import java.util.jar.JarFile

import com.google.common.cache.Cache
import org.apache.commons.lang3.ArrayUtils
import org.specs2.matcher.Matcher
import org.specs2.mutable.SpecificationWithJUnit

import scala.reflect.{ClassTag, _}

class ScalaImportExposesJarsTest extends SpecificationWithJUnit {
  val targetLabel = "//test/src/main/scala/scalarules/test/scala_import:guava_and_commons_lang"

  "scala_import" should {
    "enable using the jars it exposes" in {
      println(classOf[Cache[String, String]])
      println(classOf[ArrayUtils])
      success
    }

    "stamp jars with a target label" in {
      findManifest[Cache[String, String]] must haveTargetLabel
      findManifest[ArrayUtils] must haveTargetLabel
    }.pendingUntilFixed("runtime jars are not stamped")

    "preserve existing Manifest attributes" in {
      findManifest[ArrayUtils] must haveMainAttribute("Bundle-Name")
    }
  }

  def findManifest[T: ClassTag]: jar.Manifest = {
    val file = classTag[T].runtimeClass.getProtectionDomain.getCodeSource.getLocation.getFile
    val jar = new JarFile(file)
    val manifest = jar.getManifest
    jar.close()
    manifest
  }

  def haveTargetLabel: Matcher[jar.Manifest] = haveMainAttribute("Target-Label")

  def haveMainAttribute(attribute: String): Matcher[jar.Manifest] = {
    not(beNull[String]) ^^ { (m: jar.Manifest) =>
      m.getMainAttributes.getValue(attribute) aka s"an attribute $attribute"
    }
  }

}
