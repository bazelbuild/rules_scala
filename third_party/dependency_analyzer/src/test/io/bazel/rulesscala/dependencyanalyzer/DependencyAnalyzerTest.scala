package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import java.nio.file.Paths

import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil._

@RunWith(classOf[JUnit4])
class DependencyAnalyzerTest {
  val pluginName = "dependency_analyzer"

  def compileWithDependencyAnalyzer(code: String, withDirect: List[String] = Nil, withIndirect: List[(String, String)] = Nil): List[String] = {
    val toolboxPluginOptions: String = {
      val jar = System.getProperty(s"plugin.jar.location")
      val start= jar.indexOf(s"/third_party/$pluginName")
      // this substring is needed due to issue: https://github.com/bazelbuild/bazel/issues/2475
      val jarInRelationToBaseDir = jar.substring(start, jar.length)
      val pluginPath = Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath
      s"-Xplugin:$pluginPath -Jdummy=${pluginPath.toFile.lastModified}"
    }

    val constructParam: (String, Iterable[String]) => String = constructPluginParam("dependency-analyzer")
    val compileOptions = Seq(
      constructParam("direct-jars", withDirect),
      constructParam("indirect-jars", withIndirect.map(_._1)),
      constructParam("indirect-targets", withIndirect.map(_._2)),
      constructParam("current-target", Seq(defaultTarget))
    ).mkString(" ")

    val extraClasspath = withDirect ++ withIndirect.map(_._1)

    runCompiler(code, compileOptions, extraClasspath, toolboxPluginOptions)
  }


  @Test
  def `error on indirect dependency target`(): Unit = {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "//commons:Target"

    val indirect = List(apacheCommonsClasspath -> encodeLabel(commonsTarget))
    compileWithDependencyAnalyzer(testCode, withIndirect = indirect).expectErrorOn(commonsTarget)
  }

  @Test
  def `error on multiple indirect dependency targets`(): Unit = {
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

  @Test
  def `do not give error on direct dependency target`(): Unit = {
    val testCode =
      """object Foo {
        |  org.apache.commons.lang3.ArrayUtils.EMPTY_BOOLEAN_ARRAY.length
        |}
      """.stripMargin

    val commonsTarget = "commonsTarget"

    val direct = List(apacheCommonsClasspath)
    val indirect = List(apacheCommonsClasspath -> commonsTarget)
    val a = compileWithDependencyAnalyzer(testCode, withDirect = direct, withIndirect = indirect)
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
      s"expected an error on $target to appear in errors (with buildozer command)!")
    )

    def noErrorOn(target: String) = assert(
      !infos.exists(checkErrorContainsMessage(target)),
      s"error on $target should not appear in errors!")
  }
}
