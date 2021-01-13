package scalarules.test.stamping

import scala.language.experimental.macros
import scala.reflect.macros.blackbox

object ClassFromMacroLibrary {
  def hello(): Unit = macro helloMacro

  def helloMacro(c: blackbox.Context)(): c.Expr[Unit] = {
    import c.universe._
    reify { println("Hello World!") }
  }
}