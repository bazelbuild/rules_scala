package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import org.scalatest._
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.ScalaVersion

class ScalaVersionTest extends FunSuite {
  test("version comparison works") {
    // Test that when a > b, all the comparisons are as expected
    def testOrder(a: String, b: String): Unit = {
      val va = ScalaVersion(a)
      val vb = ScalaVersion(b)

      assert(!(va == vb))
      assert(va != vb)
      assert(!(va < vb))
      assert(!(va <= vb))
      assert(va > vb)
      assert(va >= vb)

      assert(!(vb == va))
      assert(vb != va)
      assert(vb < va)
      assert(vb <= va)
      assert(!(vb > va))
      assert(!(vb >= va))
    }

    def testEqual(a: String, b: String): Unit = {
      val va = ScalaVersion(a)
      val vb = ScalaVersion(b)

      assert(va == vb)
      assert(!(va != vb))
      assert(!(va < vb))
      assert(va <= vb)
      assert(!(va > vb))
      assert(va >= vb)
    }

    testEqual("1.1.1", "1.1.1")
    testEqual("1.2.3", "1.2.3")
    testEqual("30.20.10", "30.20.10")

    testOrder("1.2.3", "1.0.0")
    testOrder("1.2.1", "1.2.0")
    testOrder("1.2.0", "1.1.9")
    testOrder("2.12.12", "2.12.11")
    testOrder("2.12.0", "2.1.50")
  }

  test("macro works") {
    // These are rather duplicative unfortunately as the person
    // who wrote the macro is not very smart

    // We use versions like 1.0.0 and 500.0.0 so that even
    // as versions of scala change the test won't need to be updated

    // Note: this test unfortunately does not test that the min and max
    // bounds are inclusive rather than exclusive, because this code has to
    // compile across all supported scala versions and we can't get an
    // inlineable constant with the version string. In theory there may
    // be complex solutions such as making this a template file and
    // inserting the version, but that seems rather overdifficult.
    //
    // As version-differing behavior should be tested in unit tests anyways,
    // with their own version bounds checks, this seems an acceptable risk
    // given the costs of fixing.

    // No bounds
    {
      var hit = false
      ScalaVersion.conditional(
        None,
        None,
        "hit = true"
      )
      assert(hit)
    }

    // Min bounds hit
    {
      var hit = false
      ScalaVersion.conditional(
        Some("1.0.0"),
        None,
        "hit = true"
      )
      assert(hit)
    }

    // Min bounds not hit
    {
      var hit = false
      ScalaVersion.conditional(
        Some("500.0.0"),
        None,
        "hit = true"
      )
      assert(!hit)
    }

    // Max bounds hit
    {
      var hit = false
      ScalaVersion.conditional(
        None,
        Some("500.0.0"),
        "hit = true"
      )
      assert(hit)
    }

    // Max bounds not hit
    {
      var hit = false
      ScalaVersion.conditional(
        None,
        Some("1.0.0"),
        "hit = true"
      )
      assert(!hit)
    }

    // Min-max bound hit
    {
      var hit = false
      ScalaVersion.conditional(
        Some("1.0.0"),
        Some("500.0.0"),
        "hit = true"
      )
      assert(hit)
    }

    // Min-max bound not hit
    {
      var hit = false
      ScalaVersion.conditional(
        Some("500.0.0"),
        Some("1000.0.0"),
        "hit = true"
      )
      assert(!hit)
    }
  }
}
