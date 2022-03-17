package examples.testing.scalatest_repositories.example

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.must.Matchers

class ExampleTest extends FlatSpec with Matchers {
  "Exmaple" should "pass" in {
    1 must be(1)
  }
}
