package scalarules.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit

class FailingTest extends SpecWithJUnit {

  val boom: String = { throw new Exception("Boom") }

  "some test" >> { boom must beEmpty }
}
