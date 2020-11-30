package scalarules.test.io_utils

import java.io.File
import java.nio.file.Files

import io.bazel.rulesscala.io_utils.DeleteRecursively
import org.scalatest._
import flatspec._
import matchers.should._

class DeleteDirectoryTest extends AnyFlatSpec with Matchers {

  "DeleteDirectory.run" should "remove nested folders" in {
    // Arrange.
    val tempDir = Files.createTempDirectory("test-tempdir-")

    val nestedTmpDir = Files.createTempDirectory(tempDir, "abc")
    Files.createTempFile(nestedTmpDir, "test", "")
    val nestedTmpDir2 = Files.createTempDirectory(tempDir, "def")
    Files.createTempFile(nestedTmpDir2, "test", "")
    Files.createTempDirectory(tempDir, "ghi")

    // Act.
    DeleteRecursively.run(tempDir)

    // Assert.
    new File(tempDir.toUri) should not (exist)
  }
}
