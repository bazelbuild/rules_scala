package scalarules.test.junit

import org.junit.Test
import org.junit.Assert._

class TestJunitCustomPrefix {

  @Test
  def someTest: Unit = {
  	assertEquals(1, 1)
  }

}
class OtherCustomPrefixJunit {

  @Test
  def someTest: Unit = {
  	assertEquals(1, 1)
  }

}
