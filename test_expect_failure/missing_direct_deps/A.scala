package test_expect_failure.missing_direct_deps

object A {
	def foo = {
		B.foo
		C.foo
	}
}