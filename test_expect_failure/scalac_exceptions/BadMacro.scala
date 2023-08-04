import scala.language.experimental.macros

object BadMacro {
  def badMacro(): Unit = macro badMacroImpl
  def stackOverflowMacro(): Unit = macro stackOverflowMacroImpl

  def badMacroImpl(c: scala.reflect.macros.blackbox.Context)(): c.Tree = {
    throw new NoSuchMethodError()
  }

  def uhOh(n: Int): Int = n + uhOh(n + 1)

  def stackOverflowMacroImpl(c: scala.reflect.macros.blackbox.Context)(): c.Tree = {
    import c.universe._
    uhOh(1)
    q""
  }
}