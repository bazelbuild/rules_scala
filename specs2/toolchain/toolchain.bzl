load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

toolchain_type_label = "@io_bazel_rules_scala//specs2/toolchain:specs2_toolchain_type"

def _toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, toolchain_type_label)

specs2_toolchain_deps = rule(
    implementation = _toolchain_deps,
    attrs = {
        "provider_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [toolchain_type_label],
)
