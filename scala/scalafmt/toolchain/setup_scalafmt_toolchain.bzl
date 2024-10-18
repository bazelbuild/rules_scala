load("//scala/scalafmt/toolchain:toolchain.bzl", "scalafmt_toolchain")
load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_artifact_ids")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def setup_scalafmt_toolchain(
        name,
        scalafmt_classpath,
        scala_version,
        visibility = ["//visibility:public"]):
    scalafmt_classpath_provider = "%s_scalafmt_classpath_provider" % name
    declare_deps_provider(
        name = scalafmt_classpath_provider,
        deps_id = "scalafmt_classpath",
        visibility = visibility,
        deps = scalafmt_classpath,
    )
    scalafmt_toolchain(
        name = "%s_impl" % name,
        dep_providers = [scalafmt_classpath_provider],
        visibility = visibility,
    )
    native.toolchain(
        name = name,
        target_settings = [
            "@io_bazel_rules_scala_config//:scala_version" +
            version_suffix(scala_version),
        ],
        toolchain = ":%s_impl" % name,
        toolchain_type = Label(
            "//scala/scalafmt/toolchain:scalafmt_toolchain_type",
        ),
        visibility = visibility,
    )

def setup_scalafmt_toolchains():
    for scala_version in SCALA_VERSIONS:
        setup_scalafmt_toolchain(
            name = "scalafmt_toolchain" + version_suffix(scala_version),
            scala_version = scala_version,
            scalafmt_classpath = _deps(scala_version),
        )

def _deps(scala_version):
    return [
        "@" + artifact_id + version_suffix(scala_version)
        for artifact_id in scalafmt_artifact_ids(scala_version)
    ]
