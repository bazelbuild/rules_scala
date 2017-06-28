package test_expect_logs.missing_direct_deps

object B {
	def foo = {
		C.foo
	}
}