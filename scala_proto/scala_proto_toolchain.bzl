load(
    "//protoc:private/toolchain_impl.bzl",
    "PROTOC_ATTR",
    "PROTOC_TOOLCHAINS",
    "protoc_executable",
)
load("//scala:providers.bzl", "DepsInfo")
load(
    "//scala_proto/default:default_deps.bzl",
    _scala_proto_deps_providers = "scala_proto_deps_providers",
)
load("@rules_java//java/common:java_info.bzl", "JavaInfo")

def _generators_jars(ctx):
    generator_deps = ctx.attr.extra_generator_dependencies + [
        ctx.attr._main_generator_dep,
    ]
    return depset(transitive = [
        dep[JavaInfo].transitive_runtime_jars
        for dep in generator_deps
    ])

def _ignored_proto_targets_by_label(ctx):
    return {p.label: p for p in ctx.attr.blacklisted_protos}

def _worker_flags(ctx, generators, jars):
    env = dict(
        {"GEN_" + k: v for k, v in generators.items()},
        PROTOC = protoc_executable(ctx).path,
        JARS = ctx.configuration.host_path_separator.join(
            [f.path for f in jars.to_list()],
        ),
    )
    return "--jvm_flags=" + " ".join(["-D%s=%s" % i for i in env.items()])

def _scala_proto_toolchain_impl(ctx):
    generators = ctx.attr.generators
    generators_jars = _generators_jars(ctx)
    compile_dep_ids = ["scalapb_compile_deps"]
    toolchain = platform_common.ToolchainInfo(
        generators = generators,
        generators_jars = generators_jars,
        generators_opts = ctx.attr.generators_opts,
        compile_dep_ids = compile_dep_ids,
        blacklisted_protos = _ignored_proto_targets_by_label(ctx),
        protoc = protoc_executable(ctx),
        scalac = ctx.attr.scalac.files_to_run,
        worker = ctx.attr.code_generator.files_to_run,
        worker_flags = _worker_flags(ctx, generators, generators_jars),
        stamp_by_convention = ctx.attr.stamp_by_convention,
    )
    return [toolchain]

# Args:
#     blacklisted_protos: list of protobuf targets to exclude from recursive building
#     code_generator: what code generator to use, usually you'll want the default
scala_proto_toolchain = rule(
    implementation = _scala_proto_toolchain_impl,
    attrs = {
        "blacklisted_protos": attr.label_list(default = []),
        "code_generator": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//src/scala/scripts:scalapb_worker"),
            allow_files = True,
        ),
        "generators": attr.string_dict(),
        "generators_opts": attr.string_list_dict(),
        "extra_generator_dependencies": attr.label_list(
            providers = [JavaInfo],
        ),
        "scalac": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//src/java/io/bazel/rulesscala/scalac"),
            allow_files = True,
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
        # `scripts.ScalaPbCodeGenerator` and `_main_generator_dep` are currently
        # necessary to support protoc-bridge < 0.9.8, specifically 0.7.14
        # required by Scala 2.11. See #1647 and scalapb/ScalaPB#1771.
        #
        # If we drop 2.11 support, restore `scalapb.ScalaPbCodeGenerator` here,
        # remove `_main_generator_dep`, and delete
        # `//src/scala/scripts:scalapb_codegenerator_wrapper` and its files.
        "_main_generator_dep": attr.label(
            default = Label(
                "//src/scala/scripts:scalapb_codegenerator_wrapper",
            ),
            allow_single_file = True,
            executable = False,
            cfg = "exec",
        ),
    } | PROTOC_ATTR,
    toolchains = PROTOC_TOOLCHAINS,
)

def scalapb_toolchain(name, opts = [], **kwargs):
    """Sets up a scala_proto_toolchain using ScalaPB.

    Args:
        name: A unique name for this target
        opts: scalapb generator options like 'grpc' or 'flat_package'
        kwargs: remaining arguments to `scala_proto_toolchain`
    """
    scala_proto_toolchain(
        name = name,
        generators = {
            "scala": "scripts.ScalaPbCodeGenerator",
        },
        generators_opts = {
            "scala": opts,
        },
        **kwargs
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
            default = _scala_proto_deps_providers(),
            cfg = "target",
            providers = [DepsInfo],
        ),
    },
)

scala_proto_deps_providers = _scala_proto_deps_providers
