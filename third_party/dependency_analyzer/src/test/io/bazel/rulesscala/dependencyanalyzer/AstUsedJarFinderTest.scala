package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Files
import java.nio.file.Path
import org.apache.commons.io.FileUtils
import org.scalatest._
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod
import third_party.utils.src.test.io.bazel.rulesscala.utils.JavaCompileUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil.DependencyAnalyzerTestParams

class AstUsedJarFinderTest extends FunSuite {
  private def withSandbox(action: Sandbox => Unit): Unit = {
    val tmpDir = Files.createTempDirectory("dependency_analyzer_test_temp")
    val file = tmpDir.toFile
    try {
      action(new Sandbox(tmpDir))
    } finally {
      FileUtils.deleteDirectory(file)
    }
  }

  private class Sandbox(tmpDir: Path) {
    def compileWithoutAnalyzer(
      code: String
    ): Unit = {
      TestUtil.runCompiler(
        code = code,
        extraClasspath = List(tmpDir.toString),
        outputPathOpt = Some(tmpDir)
      )
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

    def checkStrictDepsErrorsReported(
      code: String,
      expectedStrictDeps: List[String]
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                indirectJars = expectedStrictDeps.map(name => tmpDir.resolve(s"$name.class").toString),
                indirectTargets = expectedStrictDeps,
                strictDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedStrictDeps.size)

      expectedStrictDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is used but isn't explicitly declared, please add it to the deps"
        assert(errors.exists(_.contains(expectedError)))
      }
    }

    def checkUnusedDepsErrorReported(
      code: String,
      expectedUnusedDeps: List[String]
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                directJars = expectedUnusedDeps.map(name => tmpDir.resolve(s"$name.class").toString),
                directTargets = expectedUnusedDeps,
                unusedDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedUnusedDeps.size)

      expectedUnusedDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is specified as a dependency to ${TestUtil.defaultTarget} but isn't used, please remove it from the deps."
        assert(errors.exists(_.contains(expectedError)))
      }
    }
  }

  /**
   * In a situation where B depends on A directly, ensure that the
   * dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.checkStrictDepsErrorsReported(
        code = bCode,
        expectedStrictDeps = List("A")
      )
    }
  }

  /**
   * In a situation where C depends on both A and B directly, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkStrictDepsErrorsReported(
        code = cCode,
        expectedStrictDeps = List("A", "B")
      )
    }
  }

  /**
   * In a situation where C depends directly on B but not on A, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkIndirectDependencyDetected(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkUnusedDepsErrorReported(
        code = cCode,
        expectedUnusedDeps = List("A")
      )
    }
  }

  test("simple composition in indirect") {
    checkIndirectDependencyDetected(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B(a: A)
          |""".stripMargin,
      cCode =
        """
          |class C(b: B)
          |""".stripMargin
    )
  }

  test("method call argument is direct") {
    checkDirectDependencyRecognized(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B {
          |  def foo(a: A = new A()): Unit = {}
          |}
          |""".stripMargin,
      cCode =
        """
          |class C {
          |  def bar(): Unit = {
          |    new B().foo(new A())
          |  }
          |}
          |""".stripMargin
    )
  }

  test("class ctor arg type parameter is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |  a: Option[A]
           |)
           |""".stripMargin
    )
  }

  test("class static annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |) extends scala.annotation.StaticAnnotation
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("method annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B {
           |  @A
           |  def foo(): Unit = {
           |  }
           |}
           |""".stripMargin
    )
  }

  test("class type parameter bound is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B[T <: A](
           |)
           |""".stripMargin
    )
  }

  test("classOf is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |) {
           |  val x: Class[_] = classOf[A]
           |}
           |""".stripMargin
    )
  }

  test("classOf in class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode = "class A",
      bCode = "class B(a: Any)",
      cCode =
        s"""
           |@B(classOf[A])
           |class C
           |""".stripMargin
    )
  }

  test("java interface method argument is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "B",
        code = "public interface B { }"
      )
      sandbox.checkStrictDepsErrorsReported(
        """
          |class C {
          |  def foo(x: B): Unit = {}
          |}
          |""".stripMargin,
        expectedStrictDeps = List("B")
      )
    }
  }
}
