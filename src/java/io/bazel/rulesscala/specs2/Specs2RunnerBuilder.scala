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

  /** Taken from specs2: replaces () with [] because it cause display issues in JUnit plugins */
  private def sanitize(testName: String) = {
    val sanitized = testName.trim.replace('(', '[').replace(')', ']')
    if (sanitized.isEmpty) " "
    else sanitized
  }

  /**
    * Retrieves an original (unsanitized) text of an example fragment,
    * used later as a regex string for specs2 matching.
    *
    * This is done by matching the actual (sanitized) string with the sanitized version
    * of the original example text.
    */
  private def specs2Description(desc: String): String = this.specStructure.examples
      .map(fragment => fragment.description.show)
      .find(sanitize(_) == desc)
      .getOrElse(desc)

  private def toDisplayName(description: Description) = description.getMethodName.split("::").reverse.headOption
    .map(specs2Description)
    .getOrElse("")

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

  private def specs2ExamplesMatching(testFilter: Pattern, junitDescription: Description): List[String] =
    flattenDescription(junitDescription)
      .filter(matching(testFilter))
      .map(toDisplayName)

  override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
    val specs2MatchedExamplesRegex = specs2ExamplesMatching(testFilter, getDescription).toRegexAlternation

    val newArgs = Arguments(select = Select(_ex = specs2MatchedExamplesRegex), commandLine = CommandLine.create(testClass.getName))
    val newEnv = env.copy(arguments overrideWith newArgs)

    super.runWithEnv(n, newEnv)
  }

  private implicit class `Empty String to Option`(s: String) {
    def toOption: Option[String] = if (s.isEmpty) None else Some(s)
    def toQuotedRegex: String = if (s.isEmpty) s else Pattern.quote(s)
  }
  private implicit class `Collection Regex Extensions`(coll: List[String]) {
    def toRegexAlternation: Option[String] =
      if (coll.isEmpty) None
      else Some(coll.map(_.toQuotedRegex).mkString("(", "|", ")"))
  }
}