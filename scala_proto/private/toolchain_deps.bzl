load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)

_DEPS_TOOLCHAIN_TYPE = Label("//scala_proto:deps_toolchain_type")

def _export_scalapb_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, _DEPS_TOOLCHAIN_TYPE)

export_scalapb_toolchain_deps = rule(
    _export_scalapb_toolchain_deps,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [_DEPS_TOOLCHAIN_TYPE],
)
