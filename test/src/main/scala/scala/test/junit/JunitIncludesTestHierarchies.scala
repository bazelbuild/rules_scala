package scala.test.junit

import org.junit.Test

abstract class ContractTest {
  @Test
  def abstractTest: Unit =
  	println("Test Method From Parent")
} 
class ConcreteImplementationTest extends ContractTest