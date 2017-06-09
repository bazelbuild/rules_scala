package io.bazel.rulesscala.test_discovery

import java.util.regex.Pattern
import org.junit.runner.Runner
import org.junit.runners.BlockJUnit4ClassRunner
import org.junit.runners.Suite
import org.junit.runners.model.FrameworkMethod
import org.junit.runners.model.RunnerBuilder
import scala.collection.JavaConverters._

class FilteredRunnerBuilder(builder: RunnerBuilder) extends RunnerBuilder {
  // Defined by --test_filter bazel flag.
  private val maybePattern = sys.env.get("TESTBRIDGE_TEST_ONLY").map(Pattern.compile(_))

  override def runnerForClass(testClass: Class[_]): Runner = {
    val runner = builder.runnerForClass(testClass)
    maybePattern match {
      case Some(pattern) => {
        runner match {
          // Regular JUnit tests.
          case _: BlockJUnit4ClassRunner => new FilteredClassRunner(testClass, pattern)
          // TODO: handle specs2
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
}
