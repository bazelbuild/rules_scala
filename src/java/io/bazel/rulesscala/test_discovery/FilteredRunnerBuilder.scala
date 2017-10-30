package io.bazel.rulesscala.test_discovery

import java.util.regex.Pattern

import org.junit.runner.manipulation.Filter
import org.junit.runner.notification.RunNotifier
import org.junit.runner.{Description, Runner}
import org.junit.runners.model.{FrameworkMethod, RunnerBuilder}
import org.junit.runners.{BlockJUnit4ClassRunner, Suite}
import org.specs2.control.Action
import org.specs2.main.{Arguments, CommandLine, Select}
import org.specs2.specification.core.Env
import org.specs2.specification.process.Stats

import scala.collection.JavaConverters._

class FilteredRunnerBuilder(builder: RunnerBuilder) extends RunnerBuilder {
  // Defined by --test_filter bazel flag.
  private val maybePattern = sys.env.get("TESTBRIDGE_TEST_ONLY").map(Pattern.compile)

  override def runnerForClass(testClass: Class[_]): Runner = {
    val runner = builder.runnerForClass(testClass)
    maybePattern match {
      case Some(pattern) => {
        runner match {
          // Regular JUnit tests.
          case _: BlockJUnit4ClassRunner => new FilteredClassRunner(testClass, pattern)
          case _: org.specs2.runner.JUnitRunner => new FilteredSpecs2ClassRunner(testClass, pattern)
          case _: Suite => runner
          case _ => runner
        }
      }
      case None => runner
    }
  }

  // For scala_junit_tests.
  class FilteredClassRunner(testClass: Class[_], pattern: Pattern)
      extends BlockJUnit4ClassRunner(testClass) {
    override def getChildren: java.util.List[FrameworkMethod] =
      super
        .getChildren
        .asScala
        .filter(method => methodMatchesPattern(method, pattern))
        .asJava

    private def methodMatchesPattern(method: FrameworkMethod, pattern: Pattern): Boolean = {
      val testCase = method.getDeclaringClass.getName + "#" + method.getName
      pattern.matcher(testCase).find
    }
  }

  class FilteredSpecs2ClassRunner(testClass: Class[_], pattern: Pattern)
      extends org.specs2.runner.JUnitRunner(testClass) {

    private def filtered(pattern: Pattern, children: List[Description]): List[Description] =
      children.flatMap { c => c :: filtered(pattern, c.getChildren.asScala.toList) }
      .filter(d => {
        val testCase = d.getClassName + "#" + d.getMethodName
        pattern.matcher(testCase).matches
      })

    override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
      val fragments = filtered(pattern, this.getDescription.getChildren.asScala.toList)
        .map(d => d.getMethodName.split("::").reverse.headOption.getOrElse(d.getMethodName))
        .mkString(",")

      // todo escape fragment if needed (e.g. contains + or other regex-specific characters)

      val newArgs = Arguments(select = Select(_ex = Some(fragments)) , commandLine = CommandLine.create(testClass.getName))
      val newEnv = env.copy(arguments overrideWith newArgs)

      super.runWithEnv(n, newEnv)
    }
  }
}
