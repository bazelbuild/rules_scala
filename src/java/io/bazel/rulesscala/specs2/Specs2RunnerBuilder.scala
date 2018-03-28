package io.bazel.rulesscala.specs2

import java.util
import java.util.regex.Pattern

import io.bazel.rulesscala.test_discovery._
import io.bazel.rulesscala.test_discovery.FilteredRunnerBuilder.FilteringRunnerBuilder
import org.junit.runner.notification.RunNotifier
import org.junit.runner.{Description, RunWith, Runner}
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder
import org.specs2.concurrent.ExecutionEnv
import org.specs2.control.Action
import org.specs2.main.{Arguments, CommandLine, Select}
import org.specs2.specification.core.Env
import org.specs2.specification.process.Stats

import scala.language.reflectiveCalls
import scala.collection.JavaConverters._
import scala.util.Try

@RunWith(classOf[Specs2PrefixSuffixTestDiscoveringSuite])
class Specs2DiscoveredTestSuite

object FilteringBuilder {
  def apply(): FilteringRunnerBuilder  =
    Specs2FilteringRunnerBuilder.f orElse JUnitFilteringRunnerBuilder.f
}

class Specs2PrefixSuffixTestDiscoveringSuite(suite: Class[Any], runnerBuilder: RunnerBuilder)
  extends Suite(
    new FilteredRunnerBuilder(runnerBuilder, FilteringBuilder()),
    PrefixSuffixTestDiscoveringSuite.discoverClasses()) {

  override def getName: String = "Aggregate Specs2 Test Suite"

  override def getChildren: util.List[Runner] =
    super.getChildren.asScala
      .collect {
        case r: FilteredSpecs2ClassRunner if r.matchesFilter => Some(r)
        case _: FilteredSpecs2ClassRunner => None
        case other => Some(other)
      }.flatten.asJava
}

object Specs2FilteringRunnerBuilder {
  val f: FilteringRunnerBuilder = {
    case (_: org.specs2.runner.JUnitRunner, testClass: Class[_], pattern: Pattern) =>
      new FilteredSpecs2ClassRunner(testClass, pattern)
  }
}

class FilteredSpecs2ClassRunner(testClass: Class[_], testFilter: Pattern)
  extends org.specs2.runner.JUnitRunner(testClass) {

  def matchesFilter: Boolean = {
    val fqn = testClass.getName + "#"
    val matcher = testFilter.matcher(fqn)
    matcher.matches() || matcher.hitEnd()
  }

  /** Taken from specs2: replaces () with [] because it cause display issues in JUnit plugins */
  private def sanitize(testName: String) = {
    val sanitized = testName.trim.replace('(', '[').replace(')', ']')
    if (sanitized.isEmpty) " "
    else sanitized
  }

  /**
    * Retrieves an original (un-sanitized) text of an example fragment,
    * used later as a regex string for specs2 matching.
    *
    * This is done by matching the actual (sanitized) string with the sanitized version
    * of the original example text.
    */
  private def specs2Description(desc: String)(implicit ee: ExecutionEnv): String =
    Try { allDescriptions[specs2_v4].fragmentDescriptions(specStructure)(ee) }
      .getOrElse(allDescriptions[specs2_v3].fragmentDescriptions(specStructure))
      .keys
      .map(fragment => fragment.description.show)
      .find(sanitize(_) == desc)
      .getOrElse(desc)

  private def toDisplayName(description: Description)(implicit ee: ExecutionEnv): Option[String] = for {
    name <- Option(description.getMethodName)
    desc <- name.split("::").reverse.headOption
  } yield specs2Description(desc)

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

  private def specs2ExamplesMatching(testFilter: Pattern, junitDescription: Description)(implicit ee: ExecutionEnv): List[String] =
    flattenDescription(junitDescription)
      .filter(matching(testFilter))
      .flatMap(toDisplayName(_))

  override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
    implicit val ee = env.executionEnv
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