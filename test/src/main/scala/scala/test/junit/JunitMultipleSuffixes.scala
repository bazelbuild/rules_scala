package scala.test.junit

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import org.junit.Assert._

class JunitSuffixE2E {

  @Test
  def someTest: Unit = {
  	println("Running E2E")
  	assertEquals(1, 1)
  }

}
class JunitSuffixIT {

  @Test
  def someTest: Unit = {
  	println("Running IT")
  	assertEquals(1, 1)
  }

}
