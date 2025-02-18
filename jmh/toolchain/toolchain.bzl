load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")
load("//scala:providers.bzl", "declare_deps_provider", _DepsInfo = "DepsInfo")
load(
    "//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
    _versioned_repositories = "repositories",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

DEP_PROVIDERS = [
    "jmh_classpath",
    "jmh_core",
    "benchmark_generator",
    "benchmark_generator_runtime",
]

def jmh_artifact_ids():
    return [
        "io_bazel_rules_scala_org_openjdk_jmh_jmh_core",
        "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm",
        "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection",
        "io_bazel_rules_scala_org_ow2_asm_asm",
        "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple",
        "io_bazel_rules_scala_org_apache_commons_commons_math3",
    ]

def jmh_repositories(
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {}):
    repositories(
        scala_version = SCALA_VERSION,
        for_artifact_ids = jmh_artifact_ids(),
        fetch_sources = False,
        maven_servers = maven_servers,
        overriden_artifacts = overriden_artifacts,
    )
    native.register_toolchains("@rules_scala_toolchains//jmh:all")

def _jmh_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

jmh_toolchain = rule(
    _jmh_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            default = [":%s_provider" % p for p in DEP_PROVIDERS],
            providers = [_DepsInfo],
        ),
    },
)

_toolchain_type = Label("//jmh/toolchain:jmh_toolchain_type")

def _export_toolchain_deps_impl(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

export_toolchain_deps = rule(
    _export_toolchain_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [_toolchain_type],
    incompatible_use_toolchain_transition = True,
)

def setup_jmh_toolchain(name):
    jmh_toolchain(
        name = "%s_impl" % name,
        dep_providers = [":%s_provider" % p for p in DEP_PROVIDERS],
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = _toolchain_type,
        visibility = ["//visibility:public"],
    )

    declare_deps_provider(
        name = "jmh_core_provider",
        deps_id = "jmh_core",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_core",
        ]),
    )

    declare_deps_provider(
        name = "jmh_classpath_provider",
        deps_id = "jmh_classpath",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple",
            "@io_bazel_rules_scala_org_apache_commons_commons_math3",
        ]),
    )

    declare_deps_provider(
        name = "benchmark_generator_provider",
        deps_id = "benchmark_generator",
        visibility = ["//visibility:public"],
        deps = [
            Label("//src/java/io/bazel/rulesscala/jar"),
        ] + _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_core",
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm",
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection",
        ]),
    )

    declare_deps_provider(
        name = "benchmark_generator_runtime_provider",
        deps_id = "benchmark_generator_runtime",
        visibility = ["//visibility:public"],
        deps = _versioned_repositories(SCALA_VERSION, [
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm",
        ]),
    )
