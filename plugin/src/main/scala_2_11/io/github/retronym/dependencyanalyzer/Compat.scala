package plugin.src.main.scala_2_11.io.github.retronym.dependencyanalyzer

import scala.tools.nsc.Settings
import scala.tools.nsc.classpath.FlatClassPathFactory

/**
  * Provides compatibility stubs for 2.11 and 2.12 Scala compilers.
  */
trait Compat {
  def getClassPathFrom(settings: Settings) = new FlatClassPathFactory(settings)
}
