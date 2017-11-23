package io.bazel.rulesscala.test_discovery

import java.io.File
import java.io.FileInputStream
import java.lang.annotation.Annotation
import java.lang.reflect.Modifier
import java.util.jar.JarInputStream
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder
import scala.annotation.tailrec

/**
 * The test running and discovery mechanism works in the following manner:
 *   - Bazel rule executes a JVM application to run tests (currently `JUnitCore`) and asks it to run
 *     the `DiscoveredTestSuite` suite.
 *   - When JUnit tries to run it, it uses the `PrefixSuffixTestDiscoveringSuite` runner
 *     to know what tests exist in the suite.
 *   - We know which tests to run by examining the entries of the target's archive.
 *   - The archive's path is passed in a system property ("bazel.discover.classes.archive.file.path").
 *   - The entries of the archive are filtered to keep only classes
 *   - Of those we filter again and keep only those which match either of the prefixes/suffixes supplied.
 *   - Prefixes are supplied as a comma separated list. System property ("bazel.discover.classes.prefixes")
 *   - Suffixes are supplied as a comma separated list. System property ("bazel.discover.classes.prefixes")
 *   - We iterate over the remaining entries and format them into classes.
 *   - At this point we tell JUnit (via the `RunnerBuilder`) what are the discovered test classes.
 *   - W.R.T. discovery semantics this is similar to how maven surefire/failsafe plugins work.
 *   - For debugging purposes one can ask to print the list of discovered classes.
 *   - This is done via an `print_discovered_classes` attribute.
 *   - The attribute is sent via "bazel.discover.classes.print.discovered"
 *
 * Additional references:
 *   - http://junit.org/junit4/javadoc/4.12/org/junit/runner/RunWith.html
 *   - http://junit.org/junit4/javadoc/4.12/org/junit/runners/model/RunnerBuilder.html
 *   - http://maven.apache.org/surefire/maven-surefire-plugin/examples/inclusion-exclusion.html
 */
@RunWith(classOf[PrefixSuffixTestDiscoveringSuite])
class DiscoveredTestSuite

class PrefixSuffixTestDiscoveringSuite(testClass: Class[Any], builder: RunnerBuilder)
  extends Suite(new FilteredRunnerBuilder(builder, JUnitFilteringRunnerBuilder.f), PrefixSuffixTestDiscoveringSuite.discoverClasses())

object PrefixSuffixTestDiscoveringSuite {

  private[rulesscala] def discoverClasses(): Array[Class[_]] = {

    val archives = archivesPath.split(',')
    val classes = archives.flatMap(discoverClassesIn)
    if (classes.isEmpty)
      throw new IllegalStateException("Was not able to discover any classes " +
                                      s"for archive=$archives, " +
                                      s"prefixes=$prefixes, " +
                                      s"suffixes=$suffixes")
    classes
  }

  private def discoverClassesIn(archivePath: String): Array[Class[_]] = {
    val archive = archiveInputStream(archivePath)
    val classes = discoverClasses(archive, prefixes, suffixesWithClassSuffix)
    archive.close()
    if (printDiscoveredClasses) {
      println("Discovered classes:")
      classes.foreach(c => println(c.getName))
    }
    classes
  }

  private def discoverClasses(archive: JarInputStream,
                              prefixes: Set[String],
                              suffixes: Set[String]): Array[Class[_]] =
    matchingEntries(archive, prefixes, suffixes)
      .map(dropFileSuffix)
      .map(fileToClassFormat)
      .filterNot(innerClasses)
      .map(Class.forName)
      .filter(concreteClasses)
      .filter(containsTests)
      .toArray

  private def matchingEntries(archive: JarInputStream,
    prefixes: Set[String],
    suffixes: Set[String]) =
        entries(archive)
          .filter(isClass)
          .filter(entry => endsWith(suffixes)(entry) || startsWith(prefixes)(entry))

  private def startsWith(prefixes: Set[String])(entry: String): Boolean = {
    val entryName = entryFileName(entry)
    prefixes.exists(entryName.startsWith)
  }

  private def endsWith(suffixes: Set[String])(entry: String): Boolean = {
    val entryName = entryFileName(entry)
    suffixes.exists(entryName.endsWith)
  }

  private def entryFileName(entry: String): String =
    new File(entry).getName

  private def dropFileSuffix(classEntry: String): String =
    classEntry.split("\\.").head

  private def fileToClassFormat(classEntry: String): String =
    classEntry.replace('/', '.')

  private def isClass(entry: String): Boolean =
    entry.endsWith(".class")

  private def entries(jarInputStream: JarInputStream) =
    Stream.continually(Option(jarInputStream.getNextJarEntry))
    .takeWhile(_.isDefined)
    .flatten
    .map(_.getName)
    .toList

  private def archiveInputStream(archivePath: String) =
    new JarInputStream(new FileInputStream(archivePath))

  private def archivesPath: String =
    System.getProperty("bazel.discover.classes.archives.file.paths") //this is set by scala_junit_test rule in scala.bzl

  private def suffixesWithClassSuffix: Set[String] =
    suffixes.map(_ + ".class")

  private def suffixes: Set[String] =
    parseProperty(System.getProperty("bazel.discover.classes.suffixes"))

  private def prefixes: Set[String] =
    parseProperty(System.getProperty("bazel.discover.classes.prefixes"))

  private def parseProperty(potentiallyEmpty: String): Set[String] =
    potentiallyEmpty.trim match {
      case emptyStr if emptyStr.isEmpty => Set[String]()
      case nonEmptyStr => nonEmptyStr.split(",").toSet
    }

  private def printDiscoveredClasses: Boolean =
    System.getProperty("bazel.discover.classes.print.discovered").toBoolean

  private def concreteClasses(testClass: Class[_]): Boolean =
    !Modifier.isAbstract(testClass.getModifiers)

  private def innerClasses(testClassName: String): Boolean =
    testClassName.contains('$')

  private def containsTests(testClass: Class[_]): Boolean =
    annotatedWithRunWith(testClass) || hasTestAnnotatedMethodsInClassHierarchy(testClass)

  private def annotatedWithRunWith(testClass: Class[_]) =
    testClass.getAnnotation(runWithAnnotation) != null

  @tailrec
  private def hasTestAnnotatedMethodsInClassHierarchy(testClass: Class[_]): Boolean =
    Option(testClass) match {
      case None => false
      case Some(currentTestClass) if hasTestAnnotatedMethodsInCurrentClass(currentTestClass) => true
      case Some(currentTestClass) => hasTestAnnotatedMethodsInClassHierarchy(currentTestClass.getSuperclass)
    }

  private def hasTestAnnotatedMethodsInCurrentClass(testClass: Class[_]): Boolean =
    testClass.getDeclaredMethods.exists { method =>
      method.getAnnotations.exists { annotation: Annotation =>
        testAnnotation.isAssignableFrom(annotation.annotationType)
      }
    }

  private val runWithAnnotation = classOf[RunWith]
  private val testAnnotation = classOf[Test]
}
