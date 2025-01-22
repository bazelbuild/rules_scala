package macros

object Main {
  def main(arguments: Array[String]): Unit = println(IdentityMacro.identityMacro("Hello, world!"))
}
