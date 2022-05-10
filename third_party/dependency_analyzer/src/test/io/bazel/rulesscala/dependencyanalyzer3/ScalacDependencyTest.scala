package io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Files
import java.nio.file.Path
import java.util.UUID
import org.scalatest.funsuite._
import io.bazel.rulesscala.utils.Scala3CompilerUtils
import io.bazel.rulesscala.utils.Scala3CompilerUtils._
import io.bazel.rulesscala.io_utils.DeleteRecursively

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
    def compile(code: String): Unit = {
      val result = runCompiler(
        code = code,
        extraClasspath = List(tmpDir.toString),
        outputPathOpt = Some(tmpDir)
      )
      assert(result.isSuccess)
    }

    def checkExactDepsNeeded(code: String, deps: List[String]): Unit = {

      def tryCompile(usedDeps: List[String]): CompileResult = {
        val subDir = tmpDir.resolve(UUID.randomUUID().toString)
        Files.createDirectory(subDir)
        usedDeps.foreach { dep =>
          Files.copy(tmpDir.resolve(s"$dep.class"), subDir.resolve(s"$dep.class"))
          Files.copy(tmpDir.resolve(s"$dep.tasty"), subDir.resolve(s"$dep.tasty"))
        }

        Scala3CompilerUtils.runCompiler(
          code = code,
          extraClasspath = List(subDir.toString)
        )
      }

      assert(tryCompile(deps).isSuccess, "Failed to compile with all deps")

      deps.foreach { toSkip =>
        val remaining = deps.filter(_ != toSkip)
        // sanity check we removed exactly one item
        assert(remaining.size + 1 == deps.size)
        assert(
          !tryCompile(remaining).isSuccess,
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
