package test_expect_failure.missing_direct_deps.internal_deps

object D {
	def foo = {
		C.foo
	}

	def main = foo
}