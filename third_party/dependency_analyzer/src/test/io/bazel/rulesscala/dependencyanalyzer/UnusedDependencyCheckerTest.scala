package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite._
import io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod
import io.bazel.rulesscala.utils.TestUtil
import io.bazel.rulesscala.utils.TestUtil._

class UnusedDependencyCheckerTest extends AnyFunSuite {
  def compileWithUnusedDependencyChecker(code: String, withDirect: List[(String, String)] = Nil): List[String] = {
    val extraClasspath = withDirect.map(_._1)

    TestUtil.runCompiler(
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
      .map(_.msg)
  }

  test("error on unused direct dependencies") {
    val testCode =
      """object Foo {
        |}
      """.stripMargin

    val commonsTarget = "//commons:Target"

    val direct = List(apacheCommonsClasspath -> encodeLabel(commonsTarget))
    val errorMesssages = compileWithUnusedDependencyChecker(testCode, withDirect = direct)

    assert(errorMesssages.exists { msg =>
      msg.contains(commonsTarget) &&
        msg.contains(s"buildozer 'remove deps $commonsTarget' $defaultTarget")
    })
  }

  test("do not error on used direct dependencies") {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "commonsTarget"

    val direct = List(apacheCommonsClasspath -> commonsTarget)

    val errorMessages = compileWithUnusedDependencyChecker(testCode, withDirect = direct)
    assert(errorMessages.isEmpty)
  }
}
