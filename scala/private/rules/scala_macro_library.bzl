load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "library_attrs",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "get_scalac_provider",
    "get_unused_dependency_checker_mode",
    "lib",
)

def _scala_macro_library_impl(ctx):
    scalac_provider = get_scalac_provider(ctx)
    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    return lib(
        ctx,
        scalac_provider.default_macro_classpath,
        False,  # don't build the ijar for macros
        unused_dependency_checker_mode,
        ctx.attr.unused_dependency_checker_ignored_targets,
    )

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}

_scala_macro_library_attrs.update(implicit_deps)

_scala_macro_library_attrs.update(common_attrs)

_scala_macro_library_attrs.update(library_attrs)

_scala_macro_library_attrs.update(resolve_deps)

# Set unused_dependency_checker_mode default to off for scala_macro_library
_scala_macro_library_attrs["unused_dependency_checker_mode"] = attr.string(
    default = "off",
    values = [
        "warn",
        "error",
        "off",
        "",
    ],
    mandatory = False,
)

scala_macro_library = rule(
    attrs = _scala_macro_library_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_macro_library_impl,
)