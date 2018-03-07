package scala.test.classpathresources

import scala.io.Source

object ObjectWithClasspathResources extends App {
  val expectedSubstrings = Map(
    "byes" -> "later",
    "hellos" -> "Bonjour",
    "more-byes" -> "more see ya",
    "more-hellos" -> "More Hello"
  )
  expectedSubstrings.foreach {
    case (resource_name, substring) => {
      val stream = getClass.getResourceAsStream("/" + resource_name)
      assert(stream != null, s"failed to find classpath resource $resource_name")
      val content = Source.fromInputStream(stream).getLines().mkString("\n")
      assert(content.contains(substring), s"classpath resource $resource_name did not contain substring $substring")
    }
  }
}
