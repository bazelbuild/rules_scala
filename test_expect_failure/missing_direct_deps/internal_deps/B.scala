package test_expect_failure.missing_direct_deps.internal_deps;

object B {
	def foo = {
		C.foo
	}

	def main = foo
}