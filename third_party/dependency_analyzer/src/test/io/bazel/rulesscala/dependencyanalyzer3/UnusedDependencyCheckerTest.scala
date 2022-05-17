package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite._
import io.bazel.rulesscala.utils.Scala3CompilerUtils
import io.bazel.rulesscala.utils.Scala3CompilerUtils._

class UnusedDependencyCheckerTest extends AnyFunSuite {
  def compileWithUnusedDependencyChecker(code: String, withDirect: List[(String, String)] = Nil): CompileResult = {
    val extraClasspath = withDirect.map(_._1)

    Scala3CompilerUtils.runCompiler(
      code = code,
      extraClasspath = extraClasspath,
      dependencyAnalyzerParamsOpt =
        Some(
          DependencyAnalyzerTestParams(
            directJars = withDirect.map(_._1),
            directTargets = withDirect.map(_._2),
            unusedDeps = true,
            dependencyTrackingMethod = DependencyTrackingMethod.HighLevel
          )
        )
    )
  }

  test("error on unused direct dependencies") {
    val testCode =
      """object Foo {
        |}
      """.stripMargin

    val commonsTarget = "//commons:Target"

    val direct = List(apacheCommonsClasspath -> encodeLabel(commonsTarget))
    val result = compileWithUnusedDependencyChecker(testCode, withDirect = direct)

    result match {
      case Success() => fail("Expected compilation to fail")
      case Failure(errorMessages) => assert(errorMessages.exists { msg =>
        msg.contains(commonsTarget) &&
          msg.contains(s"buildozer 'remove deps $commonsTarget' $defaultTarget")
      })
    }

  }

  ignore("do not error on used direct dependencies") {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "commonsTarget"

    val direct = List(apacheCommonsClasspath -> commonsTarget)

    val result = compileWithUnusedDependencyChecker(testCode, withDirect = direct)
    result match {
      case Success() => ()
      case Failure(errorMessages) => fail(s"Compilation failed with error messages: $errorMessages")
    }
  }
}
