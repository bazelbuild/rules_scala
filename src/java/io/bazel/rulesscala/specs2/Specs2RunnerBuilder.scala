package io.bazel.rulesscala.specs2

import java.util.regex.Pattern

import io.bazel.rulesscala.test_discovery.FilteredRunnerBuilder.FilteringRunnerBuilder
import io.bazel.rulesscala.test_discovery.{FilteredRunnerBuilder, JUnitFilteringRunnerBuilder, PrefixSuffixTestDiscoveringSuite}
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

  private def toDisplayName(d: Description) = d.getMethodName.split("::").reverse.headOption.getOrElse(d.getMethodName)

  /**
    * Turns a JUnit description structure into a flat list:
    *
    *  given:
    *  class MyTest extends ...{
    *    "This example" should {
    *      "Do stuff" in {
    *        ...
    *      }
  *      }
    *  }
    *
    *  Is represented as the following description:
    *
    *  MyTest
    *  |> MyTest#This example should
    *     |> MyTest#This example should::Do stuff
    *
    *  This function returns a flat list of the descriptions and their children, starting with the root.
    */
  private def flattenDescription(description: Description): List[Description] =
    description.getChildren.asScala.toList.flatMap(d => d :: flattenDescription(d))

  private def matching(testFilter: Pattern): Description => Boolean = { d =>
    val testCase = d.getClassName + "#" + d.getMethodName
    testFilter.matcher(testCase).matches
  }

  private def specs2ExamplesMatching(testFilter: Pattern, junitDescription: Description): Option[String] =
    flattenDescription(junitDescription)
      .filter(matching(testFilter))
      .map(toDisplayName)
      .mkString(",")
      .toOption

  override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
    val specs2MatchedExamples = specs2ExamplesMatching(testFilter, getDescription)

    // todo escape fragment if needed (e.g. contains + or other regex-specific characters)
    val newArgs = Arguments(select = Select(_ex = specs2MatchedExamples), commandLine = CommandLine.create(testClass.getName))
    val newEnv = env.copy(arguments overrideWith newArgs)

    super.runWithEnv(n, newEnv)
  }

  private implicit class `Empty String to Option`(s: String) {
    def toOption: Option[String] = if (s.isEmpty) None else Some(s)
  }
}