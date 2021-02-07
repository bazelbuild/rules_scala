load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
load("@io_bazel_rules_scala//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _opts(ctx):
    opts = []
    if ctx.attr.with_grpc:
        opts.append("grpc")
    if ctx.attr.with_flat_package:
        opts.append("flat_package")
    if ctx.attr.with_single_line_to_string:
        opts.append("single_line_to_proto_string")
    return ",".join(opts)

def _extra_generator_jars(ctx):
    return depset(transitive = [
        dep[JavaInfo].transitive_runtime_jars
        for dep in ctx.attr.extra_generator_dependencies
    ])

def _generators(ctx):
    g = {}
    g.update(ctx.attr.named_generators)
    g.update({"scala": ctx.attr.main_generator})
    return g

def _env(ctx):
    e = {
        "PROTOC": ctx.executable.protoc.path,
        "EXTRA_JARS": ctx.configuration.host_path_separator.join(
            [f.path for f in _extra_generator_jars(ctx).to_list()]
        ),
    }
    e.update({
        "GEN_" + k: v
        for k, v in _generators(ctx).items()
    })
    return e

def _scala_proto_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        worker = ctx.executable.code_generator,
        env = _env(ctx),
        generators = _generators(ctx),
        opts = _opts(ctx),
        extra_generator_jars = _extra_generator_jars(ctx),
        with_grpc = ctx.attr.with_grpc,
        with_flat_package = ctx.attr.with_flat_package,
        with_single_line_to_string = ctx.attr.with_single_line_to_string,
        blacklisted_protos = ctx.attr.blacklisted_protos,
        code_generator = ctx.attr.code_generator,
        main_generator = ctx.attr.main_generator,
        scalac = ctx.attr.scalac.files_to_run,
        protoc = ctx.executable.protoc,
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
            cfg = "exec",
            default = Label("@io_bazel_rules_scala//src/scala/scripts:scalapb_worker"),
            allow_files = True,
        ),
        "main_generator": attr.string(default = "scalapb.ScalaPbCodeGenerator"),
        "named_generators": attr.string_dict(),
        "extra_generator_dependencies": attr.label_list(
            providers = [JavaInfo],
        ),
        "scalac": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac"),
            allow_files = True,
        ),
        "protoc": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@com_google_protobuf//:protoc"),
        ),
    },
)

def _scala_proto_deps_toolchain(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scala_proto_deps_toolchain = rule(
    _scala_proto_deps_toolchain,
    attrs = {
        "dep_providers": attr.label_list(
            default = [
                "@io_bazel_rules_scala//scala_proto:scalapb_compile_deps_provider",
                "@io_bazel_rules_scala//scala_proto:scalapb_grpc_deps_provider",
                "@io_bazel_rules_scala//scala_proto:scalapb_worker_deps_provider",
            ],
            cfg = "target",
            providers = [DepsInfo],
        ),
    },
)

def _export_scalapb_toolchain_deps(ctx):
    return expose_toolchain_deps(ctx, "@io_bazel_rules_scala//scala_proto:deps_toolchain_type")

export_scalapb_toolchain_deps = rule(
    _export_scalapb_toolchain_deps,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    incompatible_use_toolchain_transition = True,
    toolchains = ["@io_bazel_rules_scala//scala_proto:deps_toolchain_type"],
)
