package test_expect_failure.missing_direct_deps.external_deps_file_group

object B {
	def foo = {
		println("in B")
		com.google.common.base.Strings.commonPrefix("abc", "abcd")
	}
}