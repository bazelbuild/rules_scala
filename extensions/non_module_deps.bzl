load("//third_party/repositories:repositories.bzl", "repository")
load(
    "@io_bazel_rules_scala//scala/private:macros/scala_repositories.bzl",
    _dt_patched_compiler_setup = "dt_patched_compiler_setup",
)

def _non_module_deps_impl(ctx):
    _dt_patched_compiler_setup()
    repository(
        id = "io_bazel_rules_scala_scala_library",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_compiler",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_xml",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_parser_combinators",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_interfaces",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_reflect",
        validate_scala_version = True,
    )
    repository(
        id = "org_scalameta_semanticdb_scalac",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_tasty_core",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_asm",
        validate_scala_version = True,
    )
    repository(
        id = "io_bazel_rules_scala_scala_library_2",
        validate_scala_version = True,
    )

non_module_deps = module_extension(implementation = _non_module_deps_impl)
