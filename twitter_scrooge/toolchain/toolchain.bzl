load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)
load("//scala:providers.bzl", "DepsInfo", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala_proto/default:repositories.bzl", "GUAVA_ARTIFACT_IDS")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

DEP_PROVIDERS = [
    "compile_classpath",
    "aspect_compile_classpath",
    "scrooge_generator_classpath",
    "compiler_classpath",
]

TOOLCHAIN_DEPS = [
    "libthrift",
    "scrooge_core",
    "scrooge_generator",
    "util_core",
    "util_logging",
]

def twitter_scrooge_artifact_ids(
        libthrift = None,
        scrooge_core = None,
        scrooge_generator = None,
        util_core = None,
        util_logging = None):
    artifact_ids = [
        # Mustache is needed to generate java from thrift.
        "io_bazel_rules_scala_mustache",
        "io_bazel_rules_scala_javax_annotation_api",
        "io_bazel_rules_scala_scopt",
    ] + GUAVA_ARTIFACT_IDS

    if libthrift == None:
        artifact_ids.append("libthrift")
    if scrooge_core == None:
        artifact_ids.append("io_bazel_rules_scala_scrooge_core")
    if scrooge_generator == None:
        artifact_ids.append("io_bazel_rules_scala_scrooge_generator")
    if util_core == None:
        artifact_ids.append("io_bazel_rules_scala_util_core")
    if util_logging == None:
        artifact_ids.append("io_bazel_rules_scala_util_logging")

    return artifact_ids

def _scrooge_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scrooge_toolchain = rule(
    _scrooge_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            providers = [DepsInfo],
        ),
    },
)

_toolchain_type = Label("//twitter_scrooge/toolchain:scrooge_toolchain_type")

def _export_scrooge_deps_impl(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

export_scrooge_deps = rule(
    _export_scrooge_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [_toolchain_type],
)

def setup_scrooge_toolchain(
        name,
        libthrift = None,
        scrooge_core = None,
        scrooge_generator = None,
        util_core = None,
        util_logging = None):
    version = version_suffix(SCALA_VERSION)

    if libthrift == None:
        libthrift = "@libthrift" + version
    if scrooge_core == None:
        scrooge_core = "@io_bazel_rules_scala_scrooge_core" + version
    if scrooge_generator == None:
        scrooge_generator = "@io_bazel_rules_scala_scrooge_generator" + version
    if util_core == None:
        util_core = "@io_bazel_rules_scala_util_core" + version
    if util_logging == None:
        util_logging = "@io_bazel_rules_scala_util_logging" + version

    scrooge_toolchain(
        name = "%s_impl" % name,
        dep_providers = [":%s_provider" % p for p in DEP_PROVIDERS],
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = Label(_toolchain_type),
        visibility = ["//visibility:public"],
    )

    declare_deps_provider(
        name = "aspect_compile_classpath_provider",
        deps_id = "aspect_compile_classpath",
        visibility = ["//visibility:public"],
        deps = [
            "@io_bazel_rules_scala_javax_annotation_api" + version,
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
            libthrift,
            scrooge_core,
            util_core,
        ],
    )

    declare_deps_provider(
        name = "compile_classpath_provider",
        deps_id = "compile_classpath",
        visibility = ["//visibility:public"],
        deps = [
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
            libthrift,
            scrooge_core,
        ],
    )

    declare_deps_provider(
        name = "scrooge_generator_classpath_provider",
        deps_id = "scrooge_generator_classpath",
        visibility = ["//visibility:public"],
        deps = [scrooge_generator],
    )

    declare_deps_provider(
        name = "compiler_classpath_provider",
        deps_id = "compiler_classpath",
        visibility = ["//visibility:public"],
        deps = [
            "@io_bazel_rules_scala_mustache" + version,
            "@io_bazel_rules_scala_scopt" + version,
            Label("//scala/private/toolchain_deps:parser_combinators"),
            scrooge_generator,
            util_core,
            util_logging,
        ],
    )
