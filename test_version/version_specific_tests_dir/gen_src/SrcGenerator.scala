package build.bazel.rulesscala.test.srcgen

object SrcGenerator {
  def main(args: Array[String]): Unit = {
    println(s"""
object Foo {
  def hello: String = "hello ${args.toList}"
  def main(args: Array[String]): Unit = println(hello)
}""")
  }
}
