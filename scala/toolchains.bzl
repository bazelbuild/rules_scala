def scala_register_toolchains():
    native.register_toolchains("@io_bazel_rules_scala_toolchains//...:all")

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        str(Label("//scala:unused_dependency_checker_error_toolchain")),
    )
