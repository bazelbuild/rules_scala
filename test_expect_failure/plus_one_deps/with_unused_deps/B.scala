package scalarules.test_expect_failure.plus_one_deps.with_unused_deps

class B {
  def hi: String = {
    println(classOf[C])
    "hi"
  }
}