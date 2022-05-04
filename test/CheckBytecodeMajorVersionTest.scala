package scalarules.test

import java.nio.file.Files
import java.io.InputStream

import org.junit.Assert;
import org.junit.Test;

class CheckBytecodeMajorVersionTest {

  // https://stackoverflow.com/questions/27065/tool-to-read-and-display-java-class-versions
  def getBytecodeMajorVersion(classFileInput: InputStream): Int = {
    val eighthByte = classFileInput.readNBytes(8)(7)
    eighthByte.toInt
  }

  // https://stackoverflow.com/questions/9170832/list-of-java-class-file-format-major-version-numbers
  val majorVersionToJdkVersion = Map(
    52 -> 8,
    55 -> 11
  )

  @Test
  def someTest(): Unit = {

    val expectJava8 = getBytecodeMajorVersion(
      getClass
        .getClassLoader
        .getResourceAsStream("java_sources/SimpleJavaSourceFileA.class")
    )

    val expectJava11 =  getBytecodeMajorVersion(
      getClass
        .getClassLoader
        .getResourceAsStream("java_sources/SimpleJavaSourceFileB.class")
    )
      
    Assert.assertEquals(
      s"Expected Java 8 bytecode (major version 52) but got major version $expectJava8",
      8,
      majorVersionToJdkVersion(expectJava8)
    )
      
    Assert.assertEquals(
      s"Expected Java 11 bytecode (major version 55) but got major version $expectJava11",
      11,
      majorVersionToJdkVersion(expectJava11)
    )
  }
}
