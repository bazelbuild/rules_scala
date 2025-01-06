package io.bazel.rulesscala.specs2

import io.bazel.rulesscala.test_discovery.FilteredRunnerBuilder.FilteringRunnerBuilder
import io.bazel.rulesscala.test_discovery._
import org.junit.runner.notification.RunNotifier
import org.junit.runner.{Description, RunWith, Runner}
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder
import org.specs2.concurrent.ExecutionEnv
import org.specs2.control.Action
import org.specs2.fp.Tree.Node
import org.specs2.fp.{Tree, TreeLoc}
import org.specs2.main.{Arguments, CommandLine, Select}
import org.specs2.specification.core.{Env, Fragment, SpecStructure, SpecificationStructure}
import org.specs2.specification.process.Stats

import java.util
import java.util.regex.Pattern
import scala.collection.JavaConverters._
import scala.collection.immutable.Iterable
import scala.language.reflectiveCalls
import scala.util.Try
import scala.util.control.NonFatal

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
    case (parentRunner: org.specs2.runner.JUnitRunner, testClass: Class[_], pattern: Pattern) =>
      new FilteredSpecs2ClassRunner(parentRunner, testClass, pattern)
  }
}

class FilteredSpecs2ClassRunner(parentRunner: org.specs2.runner.JUnitRunner, testClass: Class[_], testFilter: Pattern)
  extends org.specs2.runner.JUnitRunner(testClass) {

  //taking it from parent so not to initialize test classes multiple times
  override lazy val specification: SpecificationStructure = parentRunner.specification

  override def getDescription(env: Env): Description = {
    try createFilteredDescription(specStructure, env.specs2ExecutionEnv)
    catch { case NonFatal(t) => env.shutdown; throw t; }
  }

  private def createFilteredDescription(specStructure: SpecStructure, ee: ExecutionEnv): Description = {
    val descTree = createDescriptionTree(ee).map(_._2)

    def bottomUp[A, B](t: Tree[A], f: ((A, Iterable[B]) => B)): Tree[B] = {
      val tbs = t.subForest.map(t => bottomUp(t, f))
      Node(f(t.rootLabel, tbs.map(_.rootLabel)), tbs)
    }

    bottomUp(descTree.toTree, {
      (description: Description, children: Iterable[Description]) =>
        children.filter(matchingFilter).foreach {
          child => description.addChild(child)
        }
        description
    }).rootLabel

    descTree.getLabel
  }

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

  private def createDescriptionTree(implicit ee: ExecutionEnv): TreeLoc[(Fragment, Description)] =
    Try(allDescriptions[specs2_v4].createDescriptionTree(specStructure)(ee))
      .getOrElse(allDescriptions[specs2_v3].createDescriptionTree(specStructure))

  private def allFragmentDescriptions(implicit ee: ExecutionEnv): Map[Fragment, Description] =
    flattenLeft(createDescriptionTree(ee).toTree).toMap

  private def flattenLeft(tree: Tree[(Fragment, Description)]): Stream[(Fragment, Description)] =
    squishLeft(tree, Stream.Empty)

  private def squishLeft(tree: Tree[(Fragment, Description)], xs: Stream[(Fragment, Description)]): Stream[(Fragment, Description)] =
    Stream.cons(tree.rootLabel, tree.subForest.reverse.foldLeft(xs)((s, t) => squishLeft(t, s)))

  /**
   * Creates a mapping from sanitized example fragment name to original (un-sanitized) text.
   */
  private def specs2FragmentNamesBySanitizedName(implicit ee: ExecutionEnv): Map[String, String] =
    allFragmentDescriptions
      .keys
      .map(fragment => fragment.description.show)
      .map(description => sanitize(description) -> description)
      .toMap

  /**
    * Turns a JUnit description structure into a flat list:
    *
    *  given:
    *  class MyTest extends ...{
    *    "This example" should {
    *      "Do stuff" in {
    *        ...
    *      }
    *    }
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
  def flattenChildren(root: Description): List[Description] = {
    root.getChildren.asScala.toList.flatMap(d => d :: flattenChildren(d))
  }

  private def matchingFilter(desc: Description): Boolean = {
    if (desc.isSuite) true
    else {
      val testCase = desc.getClassName + "#" + Option(desc.getMethodName).mkString
      testFilter.toString.r.findFirstIn(testCase).nonEmpty
    }
  }

  private def specs2Examples(implicit ee: ExecutionEnv): List[String] = {
    val names = specs2FragmentNamesBySanitizedName

    def toDisplayName(description: Description): Option[String] = for {
      name <- Option(description.getMethodName)
      desc <- name.split("::").reverse.headOption
    } yield names.getOrElse(desc, desc)

    flattenChildren(getDescription).flatMap(toDisplayName)
  }

  override def runWithEnv(n: RunNotifier, env: Env): Action[Stats] = {
    implicit val ee = env.executionEnv
    val specs2MatchedExamplesRegex = specs2Examples.toRegexAlternation

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
      else Some(coll.map(_.toQuotedRegex).mkString("^(", "|", ")$"))
  }
}
