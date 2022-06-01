import org.scalatest.funsuite._
import org.scalatest.matchers.should._

class A extends AnyFunSuite with Matchers {
  test("number is positive") {
    sys.env("a") should equal("b")
  }
}