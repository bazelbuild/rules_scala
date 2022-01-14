package scalarules.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit

class SuiteWithOneFailingTest extends SpecWithJUnit {

  "specs2 tests" >> {
    "succeed" >> success
    "fail" >> failure("boom")
  }

  "some other suite" >> {
    "do stuff" >> success
  }
}
