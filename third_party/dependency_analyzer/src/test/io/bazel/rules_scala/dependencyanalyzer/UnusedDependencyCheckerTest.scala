package third_party.dependency_analyzer.src.test.io.bazel.rules_scala.dependencyanalyzer

import java.nio.file.Paths
import org.scalatest._
import third_party.utils.src.test.io.bazel.rules_scala.utils.TestUtil._

class UnusedDependencyCheckerTest extends FunSuite {
  def compileWithUnusedDependencyChecker(code: String, withDirect: List[(String, String)] = Nil): List[String] = {
    val toolboxPluginOptions: String = {
      val jar = System.getProperty("plugin.jar.location")
      val start = jar.indexOf("/third_party/dependency_analyzer")
      // this substring is needed due to issue: https://github.com/bazelbuild/bazel/issues/2475
      val jarInRelationToBaseDir = jar.substring(start, jar.length)
      val pluginPath = Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath
      s"-Xplugin:$pluginPath -Jdummy=${pluginPath.toFile.lastModified}"
    }

    val constructParam: (String, Iterable[String]) => String = constructPluginParam("dependency-analyzer")
    val compileOptions = List(
      constructParam("direct-jars", withDirect.map(_._1)),
      constructParam("direct-targets", withDirect.map(_._2)),
      constructParam("current-target", Seq(defaultTarget)),
      constructParam("dependency-tracking-method", Seq("high-level")),
      constructParam("unused-deps-mode", Seq("error"))
    ).mkString(" ")

    val extraClasspath = withDirect.map(_._1)

    runCompiler(code, compileOptions, extraClasspath, toolboxPluginOptions)
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
