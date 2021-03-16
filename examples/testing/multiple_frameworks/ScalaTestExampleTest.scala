package examples.testing.multiple_frameworks

import org.scalatest.{FlatSpec, MustMatchers}

class ScalaTestExampleTest extends FlatSpec with MustMatchers {
  "Exmaple" should "pass" in {
    1 must be(1)
  }
}
