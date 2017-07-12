package test_expect_failure.dep_analyzer_modes

object A {
  def foo = {
    B.foo
    C.foo
  }
}