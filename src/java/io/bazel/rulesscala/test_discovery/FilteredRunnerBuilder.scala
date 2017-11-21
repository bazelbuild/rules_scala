package io.bazel.rulesscala.test_discovery

import java.util.regex.Pattern

import io.bazel.rulesscala.test_discovery.FilteredRunnerBuilder.FilteringRunnerBuilder
import org.junit.runner.Runner
import org.junit.runners.BlockJUnit4ClassRunner
import org.junit.runners.model.{FrameworkMethod, RunnerBuilder}

import scala.collection.JavaConverters._

class FilteredRunnerBuilder(builder: RunnerBuilder, filteringRunnerBuilder: FilteringRunnerBuilder) extends RunnerBuilder {
  // Defined by --test_filter bazel flag.
  private val maybePattern = sys.env.get("TESTBRIDGE_TEST_ONLY").map(Pattern.compile)

  def runnerFilter(runner: Runner, testClass: Class[_], pattern: Pattern): Runner = runner

  override def runnerForClass(testClass: Class[_]): Runner = {
    val runner = builder.runnerForClass(testClass)
    maybePattern.flatMap(pattern =>
      filteringRunnerBuilder.lift((runner, testClass, pattern))
    ).getOrElse(runner)
  }

}

object FilteredRunnerBuilder {
  type FilteringRunnerBuilder = PartialFunction[(Runner, Class[_], Pattern), Runner]
}

object JUnitFilteringRunnerBuilder {
  val f: FilteringRunnerBuilder = {
    case (_: BlockJUnit4ClassRunner, testClass: Class[_], pattern: Pattern) =>
      new FilteredJUnitClassRunner(testClass, pattern)
  }
}

class FilteredJUnitClassRunner(testClass: Class[_], pattern: Pattern)
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