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
  	scala.io.Source.fromFile(classesRegistry).getLines.toArray.map(Class.forName)
  

  private def classesRegistry: String =
  	System.getProperty("bazel.discovered.classes.file.path")

}