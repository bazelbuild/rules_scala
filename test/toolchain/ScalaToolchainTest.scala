package scala.test.toolchain

import build.bazel.tests.integration.BazelBaseTestCase
import org.specs2.mutable.{Before, SpecificationWithJUnit}
import org.specs2.specification.{BeforeAll, Scope}
import scala.collection.JavaConverters._

//noinspection TypeAnnotation
class ScalaToolchainTest extends SpecificationWithJUnit with BeforeAll {

  trait ctx extends Scope with Before {
    val bazelDriver = new BazelBaseTestCase {
      def writeFile(path: String, content: String) = scratchFile(path, content)

      def runBazel(args: String*) = bazel(args.asJava)

      def writeWorkspaceFile(workspaceName: String, repositories: List[String], toolchains: List[String]) = {
        val toolchainList = toolchains.map(toolchain => s""""$toolchain"""").mkString(",\n")
        // TODO: how to load current code as "local repository" inside the test?? what is the path
        val localRepositories = repositories.map(repoName =>
          s"""
             |local_repository(
             |  name = "$repoName",
             |  path = "./external/$repoName"
             |)
           """.stripMargin).mkString("\n")
        scratchFile("./WORKSPACE", s"workspace(name = '$workspaceName')",
          s"""
             |register_toolchains(
             |$toolchainList
             |)
             |
             |$localRepositories
             |
             |load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
             |scala_repositories()
      """.stripMargin)
      }
    }

    override def before = {bazelDriver.setUp()}
  }

  "scala_library" should {
    "test that build passes when loading default toolchain" in new ctx {
      bazelDriver.writeFile("HelloWorld.scala",
        """package test_expect_failure.scalacopts_from_toolchain
          |
          |class HelloWorld(name:String){
          |  def talk():String = {
          |    val notUsed = "No one uses me!..."
          |    s"hello $name"
          |  }
          |}""".stripMargin)
      bazelDriver.writeFile("BUILD",
        """load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")
          |load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
          |
          |scala_toolchain(
          |    name = "failing_scala_toolchain",
          |    scalacopts = ["-Ywarn-unused","-Xfatal-warnings"]
          |)
          |
          |scala_library(
          |    name = "hello_world",
          |    srcs = ["HelloWorld.scala"],
          |)
          |
        """.
          stripMargin)
      bazelDriver.writeWorkspaceFile(
        workspaceName = "rules_scala_toolchain_test",
        repositories = List("io_bazel_rules_scala"),
        toolchains = List("@io_bazel_rules_scala//scala:scala_toolchain"))
      val cmd = bazelDriver.runBazel("build", "//:hello_world")
      val exitCode: Int = cmd.run()
      val stderr = cmd.getErrorLines.asScala.mkString("\n")
      println(stderr)
      val stdout = cmd.getOutputLines.asScala.mkString("\n")
      println(stdout)
      exitCode ==== 0
    }
  }

  override def beforeAll(): Unit = BazelBaseTestCase.setUpClass()
}