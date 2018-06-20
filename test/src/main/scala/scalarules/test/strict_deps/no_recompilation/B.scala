package scalarules.test.strict_deps.no_recompilation;

object B {
	def foo = {
		C.foo
	}
}
