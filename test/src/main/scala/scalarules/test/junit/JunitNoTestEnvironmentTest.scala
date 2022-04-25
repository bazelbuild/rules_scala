package scalarules.test.junit

import org.junit.Assert.fail
import org.junit.Test

class JunitNoTestEnvironmentTest {

  @Test
  def testUnsetEnvVarIsNull: Unit = {
    System.getenv("my_unset_env_var") match {
      case null => ()
      case x => fail(s"Unexpectedly obtained my_unset_env_var=$x")
    }
  }
} 
