package third_party.unused_dependency_checker.src.test.io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Paths

import org.scalatest._
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil._

class UnusedDependencyCheckerTest extends FunSuite {
  val pluginName = "unused_dependencies_checker"

  def compileWithUnusedDependencyChecker(code: String, withDirect: List[(String, String)] = Nil): List[String] = {
    val toolboxPluginOptions: String = {
      val jar = System.getProperty(s"plugin.jar.location")
      val start = jar.indexOf(s"/third_party/$pluginName")
      // this substring is needed due to issue: https://github.com/bazelbuild/bazel/issues/2475
      val jarInRelationToBaseDir = jar.substring(start, jar.length)
      val pluginPath = Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath
      s"-Xplugin:$pluginPath -Jdummy=${pluginPath.toFile.lastModified}"
    }

    val constructParam: (String, Iterable[String]) => String = constructPluginParam("unused-dependency-checker")
    val compileOptions = List(
      constructParam("direct-jars", withDirect.map(_._1)),
      constructParam("direct-targets", withDirect.map(_._2)),
      constructParam("current-target", Seq(defaultTarget))
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

    println(errorMesssages)
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
