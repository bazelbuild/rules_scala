package test_expect_failure.missing_direct_deps.strict_disabled

object B {
	def foo = {
		C.foo
	}
}