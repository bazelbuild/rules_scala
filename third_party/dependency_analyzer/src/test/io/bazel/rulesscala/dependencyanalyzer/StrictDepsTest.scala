package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import org.scalatest._
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil._

class StrictDepsTest extends FunSuite {
  val pluginName = "dependency_analyzer"

  def compileWithDependencyAnalyzer(code: String, withDirect: List[String] = Nil, withIndirect: List[(String, String)] = Nil): List[String] = {
    val extraClasspath = withDirect ++ withIndirect.map(_._1)

    TestUtil.runCompiler(
      code = code,
      extraClasspath = extraClasspath,
      dependencyAnalyzerParamsOpt =
        Some(
          DependencyAnalyzerTestParams(
            directJars = withDirect,
            indirectJars = withIndirect.map(_._1),
            indirectTargets = withIndirect.map(_._2),
            strictDeps = true,
            dependencyTrackingMethod = DependencyTrackingMethod.HighLevel
          )
        )
    )
  }

  test("error on indirect dependency target") {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "//commons:Target"

    val indirect = List(apacheCommonsClasspath -> encodeLabel(commonsTarget))
    compileWithDependencyAnalyzer(testCode, withIndirect = indirect).expectErrorOn(commonsTarget)
  }

  test("error on multiple indirect dependency targets") {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |  com.google.common.base.Strings.commonPrefix("abc", "abcd")
        |}
      """.stripMargin

    val commonsTarget = "commonsTarget"
    val guavaTarget = "guavaTarget"

    val indirect = List(apacheCommonsClasspath -> commonsTarget, guavaClasspath -> guavaTarget)
    compileWithDependencyAnalyzer(testCode, withIndirect = indirect).expectErrorOn(commonsTarget, guavaTarget)
  }

  test("do not give error on direct dependency target") {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "commonsTarget"

    val direct = List(apacheCommonsClasspath)
    val indirect = List(apacheCommonsClasspath -> commonsTarget)
    compileWithDependencyAnalyzer(testCode, withDirect = direct, withIndirect = indirect).noErrorOn(commonsTarget)
  }

  implicit class `nice errors on sequence of strings`(infos: Seq[String]) {

    private def checkErrorContainsMessage(target: String) = { info: String =>
      info.contains(targetErrorMessage(target)) &
        info.contains(buildozerCommand(target))
    }

    private def targetErrorMessage(target: String) =
      s"Target '$target' is used but isn't explicitly declared, please add it to the deps"

    private def buildozerCommand(depTarget: String) =
      s"buildozer 'add deps $depTarget' $defaultTarget"

    def expectErrorOn(targets: String*): Unit = targets.foreach(target => assert(
      infos.exists(checkErrorContainsMessage(target)),
      s"expected an error on $target to appear in errors (with buildozer command)! Errors: $info")
    )

    def noErrorOn(target: String) = assert(
      !infos.exists(checkErrorContainsMessage(target)),
      s"error on $target should not appear in errors! Errors: $info")
  }
}
