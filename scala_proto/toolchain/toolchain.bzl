load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _toolchain_deps(ctx):
    toolchain_type_label = "@io_bazel_rules_scala//scala_proto/toolchain:proto_toolchain_type"
    return expose_toolchain_deps(ctx, toolchain_type_label)

proto_toolchain_deps = rule(
    implementation = _toolchain_deps,
    attrs = {
        "provider_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//scala_proto/toolchain:proto_toolchain_type"],
)
