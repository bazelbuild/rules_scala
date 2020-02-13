
import org.scalatest._

abstract class A extends FunSuite {
	val Number: Int

	test("number is positive") {
		assert(Number > 0)
	}
}