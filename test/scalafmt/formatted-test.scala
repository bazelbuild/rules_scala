package scalarules.test.scalafmt
import org.scalatest._
class FormatTest extends FlatSpec {
  val message = "We will format this test!"
  "FormatTest" should "be formatted" in {
    assert(message.equals("We will format this test!"))
  }
}
