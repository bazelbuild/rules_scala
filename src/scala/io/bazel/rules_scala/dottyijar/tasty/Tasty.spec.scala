package io.bazel.rules_scala.dottyijar.tasty

import io.bazel.rules_scala.dottyijar.tasty.format.DebuggingTastyFormat
import org.apache.commons.io.IOUtils
import java.io.{File, FileOutputStream, InputStream}
import java.nio.file.Files
import java.util.zip.ZipFile
import org.specs2.execute.Result
import org.specs2.mutable.SpecificationWithJUnit
import scala.jdk.CollectionConverters.*
import scala.util.control.NonFatal

class TastySpec extends SpecificationWithJUnit {

  /**
   * [[io.bazel.rules_scala.dottyijar.tasty.format.DebuggingTastyFormat]] uses global state to track the structure of
   * the TASTy file being read or written, which means that only one file can be read at a time. If we weren't using
   * `DebuggingTastyFormat` (which should be the case everywhere else besides this test), multiple TASTy files could be
   * read from and written to in parallel.
   */
  sequential

  "Tasty" should {
    def withTestCases[A](callback: List[TestCase] => A): A = {
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

    "Accurately model every TASTy file for the Scala 3 compiler" in {
      withTestCases {
        Result.foreach(_) { testCase =>
          println(s"Testing ${testCase.path}")

          val content = testCase.inputStream.readAllBytes()

          def handleTastyFormatFailure(writtenContent: Option[Array[Byte]]): Unit = {
            val i = testCase.path.lastIndexOf("/")
            val j = testCase.path.lastIndexOf(".")
            val baseName = testCase.path.slice(if (i == -1) 0 else i + 1, if (j == -1) testCase.path.length else j)

            /**
             * [[File.createTempFile]] requires the temporary file prefix to be at least three characters long.
             */
            val prefix = if (baseName.length < 3) baseName + "_" * (3 - baseName.length) else baseName
            val extractedTastyFilePath = File.createTempFile(prefix, ".tasty").toPath

            Files.write(extractedTastyFilePath, content)

            println(s"Extracted the incorrectly read TASTy file here: $extractedTastyFilePath")

            writtenContent.foreach { writtenContent =>
              val path = File.createTempFile(baseName, ".tasty").toPath

              Files.write(path, writtenContent)

              println(s"Extracted the incorrectly written TASTy file here: $path")
            }

            println("TastyFormat logs:")
            println(DebuggingTastyFormat.logs)
          }

          def tryTastyFormatOperation[A](result: => A, writtenContent: Option[Array[Byte]] = None): A = try {
            result
          } catch {
            case NonFatal(exception) =>
              handleTastyFormatFailure(writtenContent)

              throw exception
          }

          try {
            val readTasty = tryTastyFormatOperation(Tasty.read(content))
            val writtenContent = tryTastyFormatOperation(readTasty.write)
            val writtenTasty = tryTastyFormatOperation(Tasty.read(writtenContent), Some(writtenContent))

            /**
             * See the documentation for [[io.bazel.rules_scala.dottyijar.tasty.format.TastyReference.equals]] to
             * understand why we don't just compare [[content]] and [[writtenContent]] directly.
             */
            if (readTasty != writtenTasty) {
              handleTastyFormatFailure(Some(writtenContent))

              /**
               * `writtenTasty must ===(readTasty)` uses way too much memory, so we only call it if [[readTasty]] and
               * [[writtenTasty]] are unequal
               */
              writtenTasty must ===(readTasty)
            }

            success
          } finally {
            DebuggingTastyFormat.clearLogs()
          }
        }
      }
    }
  }
}

private case class TestCase(path: String, inputStream: InputStream)
