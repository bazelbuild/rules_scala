package scala.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit

class JunitSpecs2Test extends SpecWithJUnit {

  "specs2 tests" should {
    "run smoothly in bazel" >> {
      success
    }
  }
  

}
