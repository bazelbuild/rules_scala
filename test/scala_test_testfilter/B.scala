import org.scalatest.funsuite.AnyFunSuite

class B extends AnyFunSuite {

  test("test 1") {
    fail("This test should not be selected")
  }

}
