package io.bazel.rulesscala.test_discovery

import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder
/*
  The test running and discovery mechanism works in the following manner:
    - Bazel rule executes a JVM application to run tests (currently `JUnitCore`) and asks it to run 
  the `DiscoveredTestSuite` suite. 
    - When JUnit tries to run it, it uses the `TextFileSuite` runner
  to know what tests exist in the suite.
    - We know which tests to run by examining the entries of the target's archive.
    - The entries of the archive are filtered with grep in the bazel rule using the defined patterns. 
    - The matching entries are written to a file
    - It's path is passed in a system property ("bazel.discovered.classes.file.path").
    - We iterate over the entries and format them into classes.
    - At this point we tell JUnit (via the `RunnerBuilder`) what are the discovered test classes.
    - W.R.T. discovery semantics this is very similar to how maven surefire/failsafe plugins work.

  Additional references:
    - http://junit.org/junit4/javadoc/4.12/org/junit/runner/RunWith.html
    - http://junit.org/junit4/javadoc/4.12/org/junit/runners/model/RunnerBuilder.html
    - http://maven.apache.org/surefire/maven-surefire-plugin/examples/inclusion-exclusion.html
*/
@RunWith(classOf[TextFileSuite])
class DiscoveredTestSuite

class TextFileSuite(testClass: Class[Any], builder: RunnerBuilder)
  extends Suite(builder, testClass, TextFileSuite.discoveredClasses)

object TextFileSuite {

  private val discoveredClasses = readDiscoveredClasses(classesRegistry)

  private def readDiscoveredClasses(classesRegistry: String): Array[Class[_]] =
    entries(classesRegistry)
      .map(dropFileSuffix)
      .map(fileToClassFormat)
      .map(Class.forName)

  private def dropFileSuffix(classEntry: String): String =
    classEntry.split("\\.").head

  //name is too imperative. Not sure how to change to declarative
  private def fileToClassFormat(classEntry: String): String =
    classEntry.replace('/', '.')

  private def entries(classesRegistry: String): Array[String] =
    scala.io.Source.fromFile(classesRegistry).getLines.toArray

  private def classesRegistry: String =
    System.getProperty("bazel.discovered.classes.file.path")

}