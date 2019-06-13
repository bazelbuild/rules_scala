package scalarules.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit

class SuiteWithOneFailingTest extends SpecWithJUnit {

  "specs2 tests" should {
    "succeed" >> success
    "fail" >> failure("boom")
  }

  "some other suite" should {
    "do stuff" >> success
  }
}
