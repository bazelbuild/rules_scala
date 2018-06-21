package scalarules.test.junit

import org.junit.Test

abstract class SomeAbstractTest {
  @Test
  def abstractTest: Unit =
  	println("abstract")
} 

trait SomeTraitTest {
  @Test
  def traitTest: Unit =
  	println("trait")
} 

class SingleTestSoTargetWillNotFailDueToNoTestsTest {
  @Test
  def someTest: Unit =
  	println("passing")
} 
