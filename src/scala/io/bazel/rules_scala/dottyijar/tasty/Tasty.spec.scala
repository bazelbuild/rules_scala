package io.bazel.rules_scala.dottyijar.tasty

import io.bazel.rules_scala.dottyijar.tasty.format.DebuggingTastyFormat
import java.io.File
import java.nio.file.Files
import org.specs2.execute.Result
import scala.util.control.NonFatal

class TastySpec extends TastySpecification {

  /**
   * [[io.bazel.rules_scala.dottyijar.tasty.format.DebuggingTastyFormat]] uses global state to track the structure of
   * the TASTy file being read or written, which means that only one file can be read at a time. If we weren't using
   * `DebuggingTastyFormat` (which should be the case everywhere else besides this test), multiple TASTy files could be
   * read from and written to in parallel.
   */
  sequential

  "Tasty" should {
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
