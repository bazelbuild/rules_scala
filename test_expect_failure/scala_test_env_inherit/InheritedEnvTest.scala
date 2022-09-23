import org.scalatest.funsuite._
import org.scalatest.matchers.should._

class InheritedEnvTest extends AnyFunSuite with Matchers {
  test("value from inherit_env") {
    sys.env("a") should equal("b")
  }
}