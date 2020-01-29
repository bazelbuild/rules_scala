package build.bazel.rules_scala.test.srcgen

object SrcGenerator {
  def main(args: Array[String]): Unit = {
    println(s"""
object Foo {
  def hello: String = "hello ${args.toList}"
  def main(args: Array[String]): Unit = println(hello)
}""")
  }
}
