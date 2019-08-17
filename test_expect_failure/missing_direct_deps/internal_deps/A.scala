package test_expect_failure.missing_direct_deps.internal_deps;

object A {
	def foo = {
		B.foo
		C.foo
	}

	def main = foo
}
