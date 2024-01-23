load(
    "@io_bazel_rules_scala//scala/private:macros/scala_repositories.bzl",
    _dt_patched_compiler_setup = "dt_patched_compiler_setup",
)

def _non_module_deps_impl(ctx):
    _dt_patched_compiler_setup()

non_module_deps = module_extension(implementation = _non_module_deps_impl)
