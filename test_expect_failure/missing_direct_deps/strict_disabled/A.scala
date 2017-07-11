package test_expect_failure.missing_direct_deps.strict_disabled

object A {
	def foo = {
		B.foo
		C.foo
	}
}