load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

toolchain_type_label = "@io_bazel_rules_scala//scala/scalatest/toolchain:scalatest_toolchain_type"

def _scalatest_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, toolchain_type_label)

scalatest_toolchain_deps = rule(
    toolchains = [toolchain_type_label],
    attrs = {
        "provider_id": attr.string(
            mandatory = True,
        ),
    },
    implementation = _scalatest_toolchain_deps,
)
