package test_expect_logs.missing_direct_deps

object A {
	def foo = {
		B.foo
		C.foo
	}
}