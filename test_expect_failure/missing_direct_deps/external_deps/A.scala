package test_expect_failure.missing_direct_deps.external_deps

object A {
	def foo = {
		B.foo
		com.google.common.base.Strings.commonPrefix("abc", "abcd")
	}
}
