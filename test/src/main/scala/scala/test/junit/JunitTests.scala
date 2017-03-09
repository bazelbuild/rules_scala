package scala.test.junit

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import org.hamcrest.CoreMatchers._
import org.hamcrest.MatcherAssert._
import scala.test.junit.support.JUnitCompileTimeDep
import java.lang.management.ManagementFactory
import java.lang.management.RuntimeMXBean

class JunitWithDepsTest {

  @Test
  def hasCompileTimeDependencies: Unit = {
  	JUnitCompileTimeDep.hello
  }

  @Test
  def hasRuntimeDependencies: Unit = {
  	Class.forName("scala.test.junit.support.JUnitRuntimeDep")
  }

  @Test
  def supportsCustomJVMArgs: Unit = {
  	assertThat(ManagementFactory.getRuntimeMXBean().getInputArguments(),
  	 hasItem("-XX:HeapDumpPath=/some/custom/path"))
  }

}

class ClassCoveringRegressionFromTakingAllClassesInArchive