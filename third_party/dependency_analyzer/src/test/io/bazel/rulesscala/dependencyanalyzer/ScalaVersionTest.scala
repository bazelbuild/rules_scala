package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite._

class ScalaVersionTest extends AnyFunSuite {
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
}
