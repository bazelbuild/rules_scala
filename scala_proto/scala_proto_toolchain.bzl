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

def _deps_providers(ctx):
    deps = ["scalapb_compile_deps"]
    if ctx.attr.with_grpc:
        deps.append("scalapb_grpc_deps")
    return deps

def _extra_generator_jars(ctx):
    return depset(transitive = [
        dep[JavaInfo].transitive_runtime_jars
        for dep in ctx.attr.extra_generator_dependencies
    ])

def _generators(ctx):
    return dict(
        ctx.attr.named_generators,
        scala = ctx.attr.main_generator,
    )

def _env(ctx, generators, jars):
    return dict(
        {"GEN_" + k: v for k, v in generators.items()},
        PROTOC = ctx.executable.protoc.path,
        EXTRA_JARS = ctx.configuration.host_path_separator.join(
            [f.path for f in jars.to_list()],
        ),
    )

def _scala_proto_toolchain_impl(ctx):
    generators = _generators(ctx)
    extra_generator_jars = _extra_generator_jars(ctx)
    toolchain = platform_common.ToolchainInfo(
        generators = generators,
        extra_generator_jars = extra_generator_jars,
        env = _env(ctx, generators, extra_generator_jars),
        opts = _opts(ctx),
        compile_dep_ids = _deps_providers(ctx),
        blacklisted_protos = ctx.attr.blacklisted_protos,
        protoc = ctx.executable.protoc,
        scalac = ctx.attr.scalac.files_to_run,
        worker = ctx.attr.code_generator.files_to_run,
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
