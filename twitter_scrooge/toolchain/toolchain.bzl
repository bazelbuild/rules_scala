load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)
load("//scala:providers.bzl", "DepsInfo", "declare_deps_provider")
load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _versioned_repositories = "repositories",
)
load("//scala_proto/default:repositories.bzl", "GUAVA_ARTIFACT_IDS")
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

DEP_PROVIDERS = [
    "compile_classpath",
    "aspect_compile_classpath",
    "scrooge_generator_classpath",
    "compiler_classpath",
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

def twitter_scrooge(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {},
        # These target labels need maven_servers to compute sensible defaults.
        # Therefore we leave them None here.
        libthrift = None,
        scrooge_core = None,
        scrooge_generator = None,
        util_core = None,
        util_logging = None,
        register_toolchains = True):
    repositories(
        scala_version = SCALA_VERSION,
        for_artifact_ids = twitter_scrooge_artifact_ids(
            libthrift,
            scrooge_core,
            scrooge_generator,
            util_core,
            util_logging,
        ),
        maven_servers = maven_servers,
        fetch_sources = False,
        overriden_artifacts = overriden_artifacts,
    )

    if register_toolchains:
        native.register_toolchains(
            "@io_bazel_rules_scala_toolchains//twitter_scrooge:all",
        )

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

_toolchain_type = "//twitter_scrooge/toolchain:scrooge_toolchain_type"

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
    incompatible_use_toolchain_transition = True,
)

def setup_scrooge_toolchain(name):
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
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_javax_annotation_api",
            "@libthrift",
            "@io_bazel_rules_scala_scrooge_core",
            "@io_bazel_rules_scala_util_core",
        ]) + [
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
        ],
    )

    declare_deps_provider(
        name = "compile_classpath_provider",
        deps_id = "compile_classpath",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@libthrift",
            "@io_bazel_rules_scala_scrooge_core",
        ]) + [
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
        ],
    )

    declare_deps_provider(
        name = "scrooge_generator_classpath_provider",
        deps_id = "scrooge_generator_classpath",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_scrooge_generator",
        ]),
    )

    declare_deps_provider(
        name = "compiler_classpath_provider",
        deps_id = "compiler_classpath",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
            "@io_bazel_rules_scala_scrooge_generator",
            "@io_bazel_rules_scala_util_core",
            "@io_bazel_rules_scala_util_logging",
        ]) + [
            Label("//scala/private/toolchain_deps:parser_combinators"),
        ],
    )
