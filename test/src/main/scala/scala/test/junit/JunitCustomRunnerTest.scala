package scala.test.junit

import org.junit.Test
import org.junit.runner.RunWith

@RunWith(classOf[JunitCustomRunner])
class JunitCustomRunnerTest {
  @Test
  def myTest() = {
    assert(JunitCustomRunner.message == JunitCustomRunner.EXPECTED_MESSAGE,
      "JunitCustomRunner did not run, check the wiring in JUnitFilteringRunnerBuilder")
  }
}