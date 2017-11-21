package scala.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit
import scala.test.junit.support.JUnitCompileTimeDep

class JunitSpecs2Test extends SpecWithJUnit {

  "specs2 tests" should {
    "run smoothly in bazel" in {
      println(JUnitCompileTimeDep.hello)
      success
    }

    "not run smoothly in bazel" in {
      success
    }
  }
}

class JunitSpecs2AnotherTest extends SpecWithJUnit {

  "other specs2 tests" should {
    "run from another test" >> {
      println(JUnitCompileTimeDep.hello)
      success
    }

    "run from another test 2" >> {
      success
    }
  }
}

