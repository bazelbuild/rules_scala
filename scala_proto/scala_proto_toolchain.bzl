load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

def _generators(ctx):
    return dict(
        ctx.attr.named_generators,
        scala = ctx.attr.main_generator,
    )

def _generators_jars(ctx):
    return depset(transitive = [
        dep[JavaInfo].transitive_runtime_jars
        for dep in ctx.attr.extra_generator_dependencies
    ])

def _generators_opts(ctx):
    opts = []
    if ctx.attr.with_grpc:
        opts.append("grpc")
    if ctx.attr.with_flat_package:
        opts.append("flat_package")
    if ctx.attr.with_single_line_to_string:
        opts.append("single_line_to_proto_string")
    return ",".join(opts)

def _compile_dep_ids(ctx):
    deps = ["scalapb_compile_deps"]
    if ctx.attr.with_grpc:
        deps.append("scalapb_grpc_deps")
    return deps

def _ignored_proto_targets_by_label(ctx):
    return {p.label: p for p in ctx.attr.blacklisted_protos}

def _worker_flags(ctx, generators, jars):
    env = dict(
        {"GEN_" + k: v for k, v in generators.items()},
        PROTOC = ctx.executable.protoc.path,
        JARS = ctx.configuration.host_path_separator.join(
            [f.path for f in jars.to_list()],
        ),
    )
    return "--jvm_flags=" + " ".join(["-D%s=%s" % i for i in env.items()])

def _scala_proto_toolchain_impl(ctx):
    generators = _generators(ctx)
    generators_jars = _generators_jars(ctx)
    toolchain = platform_common.ToolchainInfo(
        generators = generators,
        generators_jars = generators_jars,
        generators_opts = _generators_opts(ctx),
        compile_dep_ids = _compile_dep_ids(ctx),
        blacklisted_protos = _ignored_proto_targets_by_label(ctx),
        protoc = ctx.executable.protoc,
        scalac = _scalac(ctx),
        worker = ctx.attr.code_generator.files_to_run,
        worker_flags = _worker_flags(ctx, generators, generators_jars),
        stamp_by_convention = ctx.attr.stamp_by_convention,
    )
    return [toolchain]

def _scalac(ctx):
    suffix = version_suffix(ctx.attr.scala_version)
    for scalac in ctx.attr.scalac:
        if scalac.label.name.endswith(suffix):
            return scalac.files_to_run
    return ctx.attr.scalac[0].files_to_run

# Args:
#     with_grpc: Enables generation of grpc service bindings for services
#     with_flat_package: When true, ScalaPB will not append the protofile base name to the package name
#     with_single_line_to_string: Enables generation of toString() methods that use the single line format
#     blacklisted_protos: list of protobuf targets to exclude from recursive building
#     code_generator: what code generator to use, usually you'll want the default
scala_proto_toolchain = rule(
    implementation = _scala_proto_toolchain_impl,
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
        "scalac": attr.label_list(
            cfg = "exec",
            default = [Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac" + version_suffix(version)) for version in SCALA_VERSIONS],
            allow_files = True,
        ),
        "protoc": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@com_google_protobuf//:protoc"),
        ),
        "stamp_by_convention": attr.bool(
            default = False,
            doc = """
            Stamps source code compiled by aspects according to convention:
            Aspects assume that the following naming is followed:
            for `<name>.proto file proto_library` is named `<name>_proto`, and
            `scala_proto_library` should be named `<name>_scala_proto`

            Read about recommended code organization in
            [proto rules documentation](https://docs.bazel.build/versions/master/be/protocol-buffer.html#proto_library)
            """,
        ),
        "scala_version": attr.string(
            default = SCALA_VERSION,
        ),
    },
)

def _scala_proto_deps_toolchain(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scala_proto_deps_toolchain = rule(
    implementation = _scala_proto_deps_toolchain,
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
