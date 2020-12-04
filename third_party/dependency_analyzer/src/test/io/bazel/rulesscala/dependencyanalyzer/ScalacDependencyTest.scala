package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Files
import java.nio.file.Path
import java.util.UUID
import io.bazel.rulesscala.io_utils.DeleteRecursively
import org.scalatest.funsuite._
import third_party.utils.src.test.io.bazel.rulesscala.utils.JavaCompileUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil

/**
 * Test that the scalac compiler behaves how we expect it to around
 * dependencies. That is, for given scenarios, we want to make sure
 * that scalac requires the given set of dependencies; no more and
 * no less.
 *
 * To clarify: these tests do not reflect the end result of strict/unused
 * deps as we are considering alternatives of how to mitigate scalac's
 * limitations.
 */
class ScalacDependencyTest extends AnyFunSuite {
  private def withSandbox(action: Sandbox => Unit): Unit = {
    val tmpDir = Files.createTempDirectory("dependency_analyzer_test_temp")
    try {
      action(new Sandbox(tmpDir))
    } finally {
      DeleteRecursively.run(tmpDir)
    }
  }

  private class Sandbox(tmpDir: Path) {
    def compile(
      code: String
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          outputPathOpt = Some(tmpDir)
        )
      assert(errors.isEmpty)
    }

    def compileJava(
      className: String,
      code: String
    ): Unit = {
      JavaCompileUtil.compile(
        tmpDir = tmpDir.toString,
        className = className,
        code = code
      )
    }

    def checkExactDepsNeeded(
      code: String,
      deps: List[String]
    ): Unit = {
      def doesCompileSucceed(usedDeps: List[String]): Boolean = {
        val subdir = tmpDir.resolve(UUID.randomUUID().toString)
        Files.createDirectory(subdir)
        usedDeps.foreach { dep =>
          val name = s"$dep.class"
          Files.copy(tmpDir.resolve(name), subdir.resolve(name))
        }
        val errors =
          TestUtil.runCompiler(
            code = code,
            extraClasspath = List(subdir.toString)
          )
        errors.isEmpty
      }

      assert(doesCompileSucceed(deps), s"Failed to compile with all deps")

      deps.foreach { toSkip =>
        val remaining = deps.filter(_ != toSkip)
        // sanity check we removed exactly one item
        assert(remaining.size + 1 == deps.size)
        assert(
          !doesCompileSucceed(remaining),
          s"Compile succeeded even though $toSkip was missing")
      }
    }
  }

  test("static annotation of superclass not needed") {
    withSandbox { sandbox =>
      sandbox.compile("class A extends scala.annotation.StaticAnnotation")
      sandbox.compile("@A class B")
      sandbox.checkExactDepsNeeded(
        code = "class C extends B",
        deps = List("B")
      )
    }
  }

  test("superclass of superclass needed") {
    withSandbox { sandbox =>
      sandbox.compile("class A")
      sandbox.compile("class B extends A")
      sandbox.checkExactDepsNeeded(
        code = "class C extends B",
        deps = List("A", "B")
      )
    }
  }
}
