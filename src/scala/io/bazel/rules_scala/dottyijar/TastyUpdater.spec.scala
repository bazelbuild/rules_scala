package io.bazel.rules_scala.dottyijar

import io.bazel.rules_scala.dottyijar.tasty.TastySpecification
import java.io.File
import java.nio.file.Files
import org.specs2.execute.Result
import scala.quoted.Quotes
import scala.tasty.inspector.{Inspector, TastyInspector}

class TastyUpdaterSpec extends TastySpecification {
  "TastyUpdater" should {
    "Work on every TASTy file for the Scala 3 compiler" in {
      withTestCases {
        Result.foreach(_) { testCase =>
          println(s"Testing ${testCase.path}")

          val content = testCase.inputStream.readAllBytes()
          val updatedContent = TastyUpdater.updateTastyFile(content)
          val i = testCase.path.lastIndexOf("/")
          val j = testCase.path.lastIndexOf(".")
          val baseName = testCase.path.slice(if (i == -1) 0 else i + 1, if (j == -1) testCase.path.length else j)

          /**
           * [[File.createTempFile]] requires the temporary file prefix to be at least three characters long.
           */
          val prefix = if (baseName.length < 3) baseName + "_" * (3 - baseName.length) else baseName
          val updatedTastyFilePath = File.createTempFile(prefix, ".tasty").toPath

          Files.write(updatedTastyFilePath, updatedContent)

          TastyInspector.inspectTastyFiles(List(updatedTastyFilePath.toString))(DummyInspector) must
            not(throwAn[Exception])
        }
      }
    }
  }
}

private object DummyInspector extends Inspector {
  override def inspect(using quotes: Quotes)(tastys: List[scala.tasty.inspector.Tasty[quotes.type]]): Unit = {}
}
