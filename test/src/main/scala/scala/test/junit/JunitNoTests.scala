package scala.test.junit

import org.junit.Test

class SomeHelpreForTest

class SingleTestSoTargetWillNotFailDueToNoTestsTest {
  @Test
  def someTest: Unit =
  	println("passing")
} 