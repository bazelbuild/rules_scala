package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite._

class ScalaVersionMacrosTest extends AnyFunSuite {
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
