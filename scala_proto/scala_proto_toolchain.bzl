load("//scala_proto:default_dep_sets.bzl", "DEFAULT_SCALAPB_COMPILE_DEPS", "DEFAULT_SCALAPB_GRPC_DEPS")

def _scala_proto_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        with_grpc = ctx.attr.with_grpc,
        with_flat_package = ctx.attr.with_flat_package,
        with_single_line_to_string = ctx.attr.with_single_line_to_string,
        blacklisted_protos = ctx.attr.blacklisted_protos,
        code_generator = ctx.attr.code_generator,
        extra_generator_dependencies = ctx.attr.extra_generator_dependencies,
        grpc_deps=ctx.attr.grpc_deps,
        implicit_compile_deps=ctx.attr.implicit_compile_deps,
        scalac = ctx.attr.scalac,
        named_generators = ctx.attr.named_generators,
    )
    return [toolchain]

# Args:
#     with_grpc: Enables generation of grpc service bindings for services
#     with_flat_package: When true, ScalaPB will not append the protofile base name to the package name
#     with_single_line_to_string: Enables generation of toString() methods that use the single line format
#     blacklisted_protos: list of protobuf targets to exclude from recursive building
#     code_generator: what code generator to use, usually you'll want the default
scala_proto_toolchain = rule(
    _scala_proto_toolchain_impl,
    attrs = {
        "with_grpc": attr.bool(),
        "with_flat_package": attr.bool(),
        "with_single_line_to_string": attr.bool(),
        "blacklisted_protos": attr.label_list(default = []),
        "code_generator": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@io_bazel_rules_scala//src/scala/scripts:scalapb_worker"),
            allow_files = True,
        ),
        "named_generators": attr.string_dict(),
        "extra_generator_dependencies": attr.label_list(
            providers = [JavaInfo],
        ),
        "grpc_deps": attr.label_list(
            providers = [JavaInfo],
            default = DEFAULT_SCALAPB_GRPC_DEPS,
            cfg = "target"
        ),
        "implicit_compile_deps": attr.label_list(
            providers = [JavaInfo],
            default = DEFAULT_SCALAPB_COMPILE_DEPS,
            cfg = "target"
        ),
        "scalac": attr.label(
            default = Label(
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac",
            ),
        ),
    },
)
