package scalarules.test.junit

import org.junit.Assert
import org.junit.Assert.fail
import org.junit.Test

class JunitSetTestEnvironmentTest {
  
  @Test
  def testSetEnvVarEqualsValue: Unit = {
    System.getenv("my_unset_env_var") match {
      case null => ()
      case x => fail(s"Unexpectedly obtained my_unset_env_var=$x")
    }
    Assert.assertEquals(System.getenv("my_env_var"), "my_value")  
  }
} 
