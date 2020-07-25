load("@io_bazel_rules_scala//scala:providers.bzl", _ScalacProvider = "ScalacProvider")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps", "java_info_for_deps")

_toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type"

def _common_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

common_toolchain_deps = rule(
    implementation = _common_toolchain_deps,
    attrs = {
        "depset_id": attr.string(mandatory = True),
    },
    toolchains = [_toolchain_type],
)
