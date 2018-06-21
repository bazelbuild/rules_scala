package scalarules.test.junit

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.junit.runners.Suite.SuiteClasses

@RunWith(classOf[Suite])
@SuiteClasses(Array(classOf[DeclaredInRunWith]))
class RunWithSupportedTest

class DeclaredInRunWith {
  @Test
  def runWith: Unit =
  	println("Test Method From RunWith")
}
