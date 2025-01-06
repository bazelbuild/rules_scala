package io.bazel.rules_scala.dottyijar.tasty

import java.io.{File, FileOutputStream, InputStream}
import java.nio.file.Files
import java.util.zip.ZipFile
import org.apache.commons.io.IOUtils
import org.specs2.mutable.SpecificationWithJUnit
import scala.jdk.CollectionConverters.*

class TastySpecification extends SpecificationWithJUnit {
  protected def withTestCases[A](callback: List[TestCase] => A): A = {
    val scala3CompilerJar = File.createTempFile("scala3-compiler", ".jar")
    val inputStream = getClass.getClassLoader.getResourceAsStream("scala3-compiler.jar")
    val outputStream = new FileOutputStream(scala3CompilerJar)

    try {
      try {
        IOUtils.copy(inputStream, outputStream)
      } finally {
        inputStream.close()
        outputStream.close()
      }

      val scala3CompilerZipFile = new ZipFile(scala3CompilerJar)

      callback(
        scala3CompilerZipFile
          .entries()
          .asScala
          .filter(_.getName.endsWith(".tasty"))
          .map(entry => TestCase(entry.getName, scala3CompilerZipFile.getInputStream(entry)))
          .toList,
      )
    } finally {
      Files.delete(scala3CompilerJar.toPath)
    }
  }
}

case class TestCase(path: String, inputStream: InputStream)
