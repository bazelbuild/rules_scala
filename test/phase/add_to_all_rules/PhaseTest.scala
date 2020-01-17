package scalarules.test.phase.add_to_all_rules

import org.scalatest._

class PhaseTest extends FlatSpec {
  val message = "You can customize test phases!"
  "HelloTest" should "be able to customize test phases!" in {
    assert(message.equals("You can customize test phases!"))
  }
}
