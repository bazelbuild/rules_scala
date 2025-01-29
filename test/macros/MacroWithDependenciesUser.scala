package macros

object MacroWithDependenciesUser {
  def main(arguments: Array[String]): Unit = {
    println(s"0 is even via macro: ${MacroWithDependencies.isEvenMacro(0)}")
    println(s"1 is even via macro: ${MacroWithDependencies.isEvenMacro(1)}")
    println(s"1 + 1 is even macro: ${MacroWithDependencies.isEvenMacro(1 + 1)}")
  }
}
