load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)

_toolchain_type = "//testing/toolchain:testing_toolchain_type"

def _testing_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

testing_toolchain_deps = rule(
    implementation = _testing_toolchain_deps,
    attrs = {
        "deps_id": attr.string(mandatory = True),
    },
    toolchains = [_toolchain_type],
)
