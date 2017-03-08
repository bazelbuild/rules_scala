package scala.test.junit

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import org.junit.Assert._

class JunitCustomSuffixE2E {

  @Test
  def someTest: Unit = {
  	assertEquals(1, 1)
  }

}
