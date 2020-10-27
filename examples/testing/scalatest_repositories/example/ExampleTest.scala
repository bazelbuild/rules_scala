package examples.testing.scalatest_repositories.example

import org.scalatest.{FlatSpec, MustMatchers}

class ExampleTest extends FlatSpec with MustMatchers {
  "Exmaple" should "pass" in {
    1 must be(1)
  }
}
