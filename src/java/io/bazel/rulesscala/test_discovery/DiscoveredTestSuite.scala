package io.bazel.rulesscala.test_discovery

import org.junit.runner.RunWith
import org.junit.runner.Runner
import org.junit.runners.Suite
import org.junit.runners.model.RunnerBuilder

@RunWith(classOf[TextFileSuite])
class DiscoveredTestSuite

class TextFileSuite(testClass: Class[Any], builder: RunnerBuilder) 
	extends Suite(builder, testClass, TextFileSuite.discoveredClasses)

object TextFileSuite {

  private val discoveredClasses = readDiscoveredClasses(classesRegistry)

  private def readDiscoveredClasses(classesRegistry: String): Array[Class[_]] =
  	classEntries(classesRegistry)
  		.map(filterTimeStampAndWhitespace)
  		.map(dropFileSuffix)
  		.map(fileToClassFormat)
  		.map(Class.forName)

  private def filterTimeStampAndWhitespace(classEntry: String): String = 
  	classEntry.split("\\s+").last

  private def dropFileSuffix(classEntry: String): String = 
  	classEntry.split("\\.").head

  //name is too imperative. Not sure how to change to declarative
  private def fileToClassFormat(classEntry: String): String = 
  	classEntry.replace('/', '.')

  private def classEntries(classesRegistry: String): Array[String] =
  	scala.io.Source.fromFile(classesRegistry).getLines.toArray

  private def classesRegistry: String =
  	System.getProperty("bazel.discovered.classes.file.path")

}