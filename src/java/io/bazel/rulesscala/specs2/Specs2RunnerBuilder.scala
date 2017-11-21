package io.bazel.rulesscala.specs2

import java.util.regex.Pattern

import io.bazel.rulesscala.test_discovery.FilteredRunnerBuilder.FilteringRunnerBuilder
import io.bazel.rulesscala.test_discovery._
import org.junit.runner.notification.RunNotifier
import org.junit.runner.{Description, RunWith}
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder
import org.specs2.control.Action
import org.specs2.main.{Arguments, CommandLine, Select}
import org.specs2.specification.core.Env
import org.specs2.specification.process.Stats

import scala.collection.JavaConverters._

@RunWith(classOf[Specs2PrefixSuffixTestDiscoveringSuite])
class Specs2DiscoveredTestSuite

class Specs2PrefixSuffixTestDiscoveringSuite(testClass: Class[Any], builder: RunnerBuilder)
  extends Suite(
    new FilteredRunnerBuilder(builder,
      Specs2FilteringRunnerBuilder.f.orElse(JUnitFilteringRunnerBuilder.f)),
    PrefixSuffixTestDiscoveringSuite.discoverClasses())

object Specs2FilteringRunnerBuilder {
  val f: FilteringRunnerBuilder = {
    case (_: org.specs2.runner.JUnitRunner, testClass: Class[_], pattern: Pattern) =>
      new Specs2ClassRunner(testClass, pattern)
  }
}

class Specs2ClassRunner(testClass: Class[_], testFilter: Pattern)
  extends org.specs2.runner.JUnitRunner(testClass) {

  private def specs2ExamplesMatching(pattern: Pattern, children: List[Description]): List[Description] = //still pattern
    children.flatMap { c => c :: specs2ExamplesMatching(pattern, c.getChildren.asScala.toList) } //why are you flattening? why is this c and the other one is d, they're the same type
      .filter(d => {
      val testCase = d.getClassName + "#" + d.getMethodName
      pattern.matcher(testCase).matches
    })

  private def toDisplayName(d: Description) = d.getMethodName.split("::").reverse.headOption.getOrElse(d.getMethodName)

  def translate(junitDescription: Description, using: Pattern): Option[String] = //using unused
    specs2ExamplesMatching(testFilter, this.getDescription.getChildren.asScala.toList)
      .map(toDisplayName)
      .mkString(",")
      .toOption

  override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
    val specs2MatchedExamples = translate(junitDescription = this.getDescription, using = testFilter)

    // todo escape fragment if needed (e.g. contains + or other regex-specific characters)
    val newArgs = Arguments(select = Select(_ex = specs2MatchedExamples), commandLine = CommandLine.create(testClass.getName))
    val newEnv = env.copy(arguments overrideWith newArgs)

    super.runWithEnv(n, newEnv)
  }

  private implicit class `Empty String to Option`(s: String) {
    def toOption: Option[String] = if (s.isEmpty) None else Some(s)
  }

}