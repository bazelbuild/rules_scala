package foo

import scala.io.Source

import org.scalatest.flatspec._


class TestResourceJars extends AnyFlatSpec {
  "this jar" should "contain resources from its resource jar dependency" in {
    val expectedSubstrings = Map(
      "byes" -> "later",
      "hellos" -> "Bonjour",
      "more-byes" -> "more see ya",
      "more-hellos" -> "More Hello"
    )
    expectedSubstrings.foreach {
      case (resource_name, substring) => {
        val stream = getClass.getResourceAsStream("/" + resource_name)
        assert(stream != null, s"failed to find resource $resource_name")
        val content = Source.fromInputStream(stream).getLines().mkString("\n")
        assert(content.contains(substring), s"resource $resource_name did not contain substring $substring")
      }
    }
  }
}
