load("@io_bazel_rules_scala//scala:providers.bzl", _ScalacProvider = "ScalacProvider")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps", "java_info_for_deps")

_toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type"

def _scala_toolchain_deps(ctx):
    from_classpath = ctx.attr.from_classpath

    scalac_provider = ctx.toolchains[_toolchain_type].scalac_provider_attr[_ScalacProvider]
    classpath_deps = getattr(scalac_provider, from_classpath)
    return java_info_for_deps(classpath_deps)

scala_toolchain_deps = rule(
    implementation = _scala_toolchain_deps,
    attrs = {
        "from_classpath": attr.string(mandatory = True),
    },
    toolchains = [_toolchain_type],
)

def _common_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

common_toolchain_deps = rule(
    implementation = _common_toolchain_deps,
    attrs = {
        "provider_id": attr.string(mandatory = True),
    },
    toolchains = [_toolchain_type],
)
