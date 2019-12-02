package scalarules.test.phase

import org.scalatest._

class HelloTest extends FlatSpec {
  val message = "You can customize test phases!"
  "HelloTest" should "be able to customize test phases!" in {
    assert(message.equals("You can customize test phases!"))
  }
}
