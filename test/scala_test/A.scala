import org.scalatest.funsuite._

abstract class A extends AnyFunSuite {
  val Number: Int

  test("number is positive") {
    assert(Number > 0)
  }
}