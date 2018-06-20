package scalarules.test.junit

import org.junit.Test
import org.junit.Assert._

class JunitSuffixE2E {

  @Test
  def someTest: Unit = {
  	assertEquals(1, 1)
  }

}
class JunitSuffixIT {

  @Test
  def someTest: Unit = {
  	assertEquals(1, 1)
  }

}
