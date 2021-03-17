package example

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.must.Matchers

class ScalaTestExampleTest extends AnyFlatSpec with Matchers {
  "Exmaple" should "pass" in {
    1 must be(1)
  }
}
