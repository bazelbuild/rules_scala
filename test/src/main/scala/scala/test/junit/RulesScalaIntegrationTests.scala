package scala.test.junit

import build.bazel.tests.integration.BazelBaseTestCase
import org.junit.{Assert, Test}
import scala.collection.JavaConverters._

class RulesScalaIntegrationTests extends BazelBaseTestCase {

  private val NoTestsFoundExitCode = 3
  private val NoTestsFoundLabel = "no_tests_found"

  @Test
  def singleTestSoTargetWillNotFailDueToNoTestsTest: Unit = {
    givenRulesScalaWorkspaceFile()
    givenBuildFile()
    givenEmptyTestSuitFile()

    val cmd = driver.bazelCommand("test", "//...").build()
    val exitCode = cmd.run()
    val errorOutput = cmd.getErrorLines.asScala

    assertNoTestsFoundCorrectOutput(errorOutput, exitCode)
  }

  private def assertNoTestsFoundCorrectOutput(output: Seq[String], exitCode: Int): Unit = {
    Assert.assertEquals(exitCode, NoTestsFoundExitCode )
    val hasCorrectOutput = output.exists(line => {
      line.contains("FAIL") && line.contains(NoTestsFoundLabel)
    })

    Assert.assertTrue(hasCorrectOutput)
  }

  private def givenRulesScalaWorkspaceFile(): Unit = {
    val workspace =
      """
        |rules_scala_version="a8ef632b1b020cdf2c215ecd9fcfa84bc435efcb" # update this as needed
        |
        |http_archive(
        | name = "io_bazel_rules_scala",
        | url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip"%rules_scala_version,
        | type = "zip",
        | strip_prefix= "rules_scala-%s" % rules_scala_version
        |)
        |
        |load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
        |scala_register_toolchains()
        |
        |load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
        |scala_repositories()
        |
        |load("@io_bazel_rules_scala//junit:junit.bzl", "junit_repositories")
        |junit_repositories()
      """.stripMargin
    driver.scratchFile("WORKSPACE", workspace)
  }

  private def givenBuildFile(): Unit = {
    val build =
      s"""
        |load("@io_bazel_rules_scala//scala:scala.bzl", "scala_junit_test")
        |
        |scala_junit_test(
        |    name = "$NoTestsFoundLabel",
        |    srcs = ["JunitTest.scala"],
        |    suffixes = ["WrongTestSuffix"],
        |    size = "small"
        |)
      """.stripMargin
    driver.scratchFile("BUILD", build)
  }

  private def givenEmptyTestSuitFile(): Unit = {
    val junitTest =
      """
        |import org.junit.Test
        |class JunitTest {
        |  @Test
        |  def running: Unit = {
        |  }
        |}
      """.stripMargin

    driver.scratchFile("JunitTest.scala", junitTest)
  }

}
