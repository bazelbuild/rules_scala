package test_expect_failure.missing_direct_deps.internal_deps

object HasCustomJavaProviderDependency {
  def foo = {
    C.foo
  }

}