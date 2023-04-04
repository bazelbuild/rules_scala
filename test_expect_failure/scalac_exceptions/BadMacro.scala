import scala.language.experimental.macros

object BadMacro {
  def badMacro(): Unit = macro badMacroImpl

  def badMacroImpl(c: scala.reflect.macros.blackbox.Context)(): c.Tree = {
    throw new NoSuchMethodError()
  }
}