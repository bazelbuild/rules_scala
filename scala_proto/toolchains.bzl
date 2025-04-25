load(
    "//scala_proto:scala_proto_toolchain.bzl",
    "scala_proto_deps_toolchain",
    "scalapb_toolchain",
)

TOOLCHAIN_DEFAULTS = {
    "default_gen_opts": ["grpc"],
}

def setup_scala_proto_toolchains(
        name,
        default_gen_opts = ["grpc"]):
    """Used by @rules_scala_toolchains//scala_proto/BUILD.

    See //scala/private:macros/toolchains_repo.bzl for details, especially the
    _SCALA_PROTO_TOOLCHAIN_BUILD string template.

    Args:
      name: prefix for all generate toolchains
      default_gen_opts: parameters passed to the default generator
    """
    scala_proto_deps_toolchain(
        name = "%s_default_deps_toolchain_impl" % name,
        dep_providers = [
            ":scalapb_%s_deps_provider" % p
            for p in ["compile", "worker"]
        ],
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = "%s_default_deps_toolchain" % name,
        toolchain = ":%s_default_deps_toolchain_impl" % name,
        toolchain_type = Label("//scala_proto:deps_toolchain_type"),
    )

    toolchain_name = "%s_default_toolchain" % name
    toolchain_impl_name = "%s_default_toolchain_impl" % name

    scalapb_toolchain(
        name = toolchain_impl_name,
        opts = default_gen_opts,
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = toolchain_name,
        toolchain = ":" + toolchain_impl_name,
        toolchain_type = Label("//scala_proto:toolchain_type"),
        visibility = ["//visibility:public"],
    )
