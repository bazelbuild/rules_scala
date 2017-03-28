package scala.test.junit.specs2

import org.specs2.mutable.SpecWithJUnit
import scala.test.junit.support.JUnitCompileTimeDep

class JunitSpecs2Test extends SpecWithJUnit {

  "specs2 tests" should {
    "run smoothly in bazel" >> {
      println(JUnitCompileTimeDep.hello)
      success
    }
  }
  

}
