package scalarules.test.stamping

import java.util.jar.JarFile

import org.scalatest.freespec._

import scala.reflect.{ClassTag, classTag}

class JarStampingTest extends AnyFreeSpec {
  "stamps scala library" in {
    val label = "//test/src/main/scala/scalarules/test/stamping:any_scala_library"
    assert(findTargetLabel[ClassFromLibrary].contains(label))
  }

  "stamps scala macro library" in {
    val label = "//test/src/main/scala/scalarules/test/stamping:any_scala_macro_library"
    assert(findTargetLabel[ClassFromMacroLibrary.type].contains(label))
  }

  def findTargetLabel[T: ClassTag]: Option[String] = {
    val file = classTag[T].runtimeClass.getProtectionDomain.getCodeSource.getLocation.getFile
    val jar = new JarFile(file)
    val targetLabel = jar.getManifest.getMainAttributes.getValue("Target-Label")
    jar.close()
    Option(targetLabel)
  }
}
