package scalarules.test.junit

import org.junit.Test
import org.hamcrest.CoreMatchers._
import org.hamcrest.MatcherAssert._
import scalarules.test.junit.support.JUnitCompileTimeDep
import java.lang.management.ManagementFactory
import java.lang.management.RuntimeMXBean

class JunitWithDepsTest {

  @Test
  def hasCompileTimeDependencies: Unit = {
  	println(JUnitCompileTimeDep.hello)
  }

  @Test
  def hasRuntimeDependencies: Unit = {
  	Class.forName("scalarules.test.junit.support.JUnitRuntimeDep")
  }

  @Test
  def supportsCustomJVMArgs: Unit = {
  	assertThat(ManagementFactory.getRuntimeMXBean().getInputArguments(),
  	 hasItem("-XX:HeapDumpPath=/some/custom/path"))
  }

}

class ClassCoveringRegressionFromTakingAllClassesInArchive
