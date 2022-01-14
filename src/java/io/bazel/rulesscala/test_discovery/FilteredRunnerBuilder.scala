package io.bazel.rulesscala.test_discovery

import FilteredRunnerBuilder.FilteringRunnerBuilder

import java.lang.annotation.Annotation
import java.util
import java.util.regex.Pattern
import org.junit.Test
import org.junit.runner.Runner
import org.junit.runners.BlockJUnit4ClassRunner
import org.junit.runners.model.{FrameworkMethod, RunnerBuilder, TestClass}

import scala.collection.JavaConverters._

object FilteredRunnerBuilder {
  type FilteringRunnerBuilder = PartialFunction[(Runner, Class[_], Pattern), Runner]
}

class FilteredRunnerBuilder(builder: RunnerBuilder, filteringRunnerBuilder: FilteringRunnerBuilder) extends RunnerBuilder {
  // Defined by --test_filter bazel flag.
  private val maybePattern = sys.env.get("TESTBRIDGE_TEST_ONLY").map(Pattern.compile)

  override def runnerForClass(testClass: Class[_]): Runner = {
    val runner = builder.runnerForClass(testClass)
    maybePattern.flatMap(pattern =>
      filteringRunnerBuilder.lift((runner, testClass, pattern))
    ).getOrElse(runner)
  }
}

private[rulesscala] class FilteredTestClass(testClass: Class[_], pattern: Pattern) extends TestClass(testClass) {
  override def getAnnotatedMethods(aClass: Class[_ <: Annotation]): util.List[FrameworkMethod] = {
    val methods = super.getAnnotatedMethods(aClass)
    if (aClass == classOf[Test])
      methods.asScala.filter(method => methodMatchesPattern(method, pattern)).asJava
    else
      methods
  }

  private def methodMatchesPattern(method: FrameworkMethod, pattern: Pattern): Boolean = {
    val testCase = method.getDeclaringClass.getName + "#" + method.getName
    pattern.matcher(testCase).find
  }
}

object JUnitFilteringRunnerBuilder {
  private final val TestClassFieldPreJUnit4_12 = "fTestClass"
  private final val TestClassField = "testClass"

  val f: FilteringRunnerBuilder = {
    case (runner: BlockJUnit4ClassRunner, testClass: Class[_], pattern: Pattern) =>
      replaceRunnerTestClass(runner, testClass, pattern)
  }

  private def replaceRunnerTestClass(runner: BlockJUnit4ClassRunner, testClass: Class[_], pattern: Pattern) = {
    allFieldsOf(runner.getClass)
      .find(f => f.getName == TestClassField || f.getName == TestClassFieldPreJUnit4_12)
      .foreach(field => {
        field.setAccessible(true)
        field.set(runner, new FilteredTestClass(testClass, pattern))
      })
    runner
  }

  private def allFieldsOf(clazz: Class[_]) = {
    def supers(cl: Class[_]): List[Class[_]] = {
      if (cl == null) Nil else cl :: supers(cl.getSuperclass)
    }

    supers(clazz).flatMap(_.getDeclaredFields)
  }
}
