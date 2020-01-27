package io.bazel.rules_scala.discover_tests_runner

import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.Result
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.FrameworkDiscovery
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.SubclassDiscovery

import sbt.testing.Event
import sbt.testing.EventHandler
import sbt.testing.Framework
import sbt.testing.Logger
import sbt.testing.Runner
import sbt.testing.SubclassFingerprint
import sbt.testing.SuiteSelector
import sbt.testing.Task
import sbt.testing.TaskDef

import java.io.FileInputStream
import java.nio.file.Paths

import scala.collection.JavaConverters._
import scala.annotation.tailrec

object DiscoverTestsRunner {

  def main(args: Array[String]): Unit = {
    val input = new FileInputStream(Paths.get(sys.props("DiscoveredTestsResult")).toFile)
    val result: Result = Result.parseFrom(input)
    input.close()

    result.getFrameworkDiscoveriesList.asScala
      .foreach(frameworkDiscovery => handleFrameworkDiscovery(frameworkDiscovery, args))

    sys.exit(0)
  }

  def handleFrameworkDiscovery(frameworkDiscovery: FrameworkDiscovery, args: Array[String]): Unit = {
    println(s"> beginning run of ${frameworkDiscovery.getFramework}")
    val framework: Framework = Class.forName(frameworkDiscovery.getFramework).newInstance.asInstanceOf[Framework]
    val runner: Runner = framework.runner(args, Array.empty, Thread.currentThread.getContextClassLoader)

    val subclassFingerprintMap: Map[(String, Boolean, Boolean), SubclassFingerprint] = framework.fingerprints.collect {
      case fingerprint: SubclassFingerprint => (fingerprint.superclassName, fingerprint.isModule, fingerprint.requireNoArgConstructor) -> fingerprint
    }.toMap

    frameworkDiscovery.getSubclassDiscoveriesList
      .asScala
      .foreach { subclassDiscovery =>
        val fingerprint: SubclassFingerprint = subclassFingerprintMap.get((subclassDiscovery.getSuperclassName, subclassDiscovery.getIsModule, subclassDiscovery.getRequireNoArgConstructor))
          .getOrElse(sys.error(s"Unable to resolve fingerprint instance for $subclassDiscovery"))

        handleTests(runner, fingerprint, subclassDiscovery.getTestsList.asScala.toList)
      }

    println(runner.done())
    println(s"< run of ${frameworkDiscovery.getFramework} complete")
  }

  def handleTests(runner: Runner, fingerprint: SubclassFingerprint, tests: List[String]): Unit = {
    val eventHandler: EventHandler = new EventHandler {
      def handle(event: Event): Unit = {
        //println(s"- $event")
      }
    }
    val loggers: Array[Logger] = Array(new Logger {
      def ansiCodesSupported(): Boolean = true
      def debug(msg: String): Unit = println(s"debug: $msg")
      def error(msg: String): Unit = println(s"error: $msg")
      def info(msg: String): Unit = println(s"info: $msg")
      def trace(e: Throwable): Unit = e.printStackTrace
      def warn(msg: String): Unit = println(s"warn: $msg")
    })

    @tailrec def execute(tasks: List[Task]): Unit = tasks match {
      case head :: tail =>
        execute(head.execute(eventHandler, loggers) ++: tail)
      case Nil =>
        ()
    }

    execute(runner
      .tasks(tests.map(test => new TaskDef(test, fingerprint, true, Array(new SuiteSelector))).toArray).toList)

  }

}
