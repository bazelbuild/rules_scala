package test.v2

import org.scalatest.FunSuite

class Test extends FunSuite {
  test("method1") {
    assert(Library.method1 == "hello")
  }

  test("method2") {
    assert(Library.method2 == "world")
  }
}
