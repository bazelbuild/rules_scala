package scalarules.test.junit.separate_target

import org.junit.Test

class FailingTest {

  @Test
  def someFailingTest(): Unit = {
    throw new RuntimeException("boom! should not run")
  }

}

