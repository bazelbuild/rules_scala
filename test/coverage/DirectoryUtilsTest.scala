package coverage;
import org.scalatest._
import java.nio.file.Files
import java.io.File
import io.bazel.rulesscala.coverage.instrumenter.DirectoryUtils

class TestAll extends FlatSpec with Matchers {

  "DirectoryUtils.deleteTempDir" should "remove nested folders" in {
    // Arrange.
    val tempDir = Files.createTempDirectory("test-tempdir-")

    val nestedTmpDir = Files.createTempDirectory(tempDir, "abc")
    Files.createTempFile(nestedTmpDir, "test", "")
    val nestedTmpDir2 = Files.createTempDirectory(tempDir, "def")
    Files.createTempFile(nestedTmpDir2, "test", "")
    Files.createTempDirectory(tempDir, "ghi")

    // Act.
    DirectoryUtils.deleteTempDir(tempDir)

    // Assert.
    new File(tempDir.toUri) should not (exist)
  }
}
