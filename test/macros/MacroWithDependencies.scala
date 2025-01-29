package macros

import scala.language.experimental.macros
import scala.reflect.macros.blackbox

object MacroWithDependencies {
  def isEvenMacro(number: Int): Boolean = macro isEvenMacroImpl
  def isEvenMacroImpl(context: blackbox.Context)(number: context.Expr[Int]): context.Expr[Boolean] = {
    import context.universe._

    val value = number.tree match {
      case Literal(Constant(value: Int)) => value
      case _ => throw new Exception(s"Expected ${number.tree} to be a literal.")
    }

    context.Expr(Literal(Constant(MacroDependency.isEven(value))))
  }
}
