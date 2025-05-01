package macros

import scala.language.experimental.macros
import scala.reflect.macros.blackbox

object IdentityMacro {
  def identityMacro[A](value: A): A = macro identityMacroImpl[A]
  def identityMacroImpl[A](context: blackbox.Context)(value: context.Expr[A]): context.Expr[A] = value
}
