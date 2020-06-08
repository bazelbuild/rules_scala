package scalacopts

import scala.reflect.macros.blackbox
import scala.language.experimental.macros

object Macros {
  def hello: String = macro macroSettings

  def macroSettings(c: blackbox.Context): c.Expr[String] = {
    import c.universe._
    // c.settings are the values from scalac's -Xmacro-settings
    val s = c.settings.mkString(",")
    c.Expr(q"""${s}""")
  }
}