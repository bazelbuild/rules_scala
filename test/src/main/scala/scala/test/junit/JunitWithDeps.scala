package scala.test.junit

import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import org.junit.Assert._
import scala.test.HelloLib

class JunitWithDepsTest {

  @Test
  def hasCompileTimeDependencies: Unit = {
  	HelloLib.printMessage("yo")
  }

  @Test
  def hasRuntimeDependencies: Unit = {
  	Class.forName("scala.test.junit.support.JUnitRuntimeDep")
  }

}