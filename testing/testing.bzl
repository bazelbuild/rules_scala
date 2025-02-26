load("//junit:junit.bzl", "junit_artifact_ids")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scalatest:scalatest.bzl", "scalatest_artifact_ids")
load("//specs2:specs2.bzl", "specs2_artifact_ids")
load("//specs2:specs2_junit.bzl", "specs2_junit_artifact_ids")
load("//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

def _repoize(ids):
    return ["@" + id for id in ids]

JUNIT_DEPS = _repoize(junit_artifact_ids())

SCALATEST_DEPS = _repoize(scalatest_artifact_ids())

SPECS2_DEPS = _repoize(specs2_artifact_ids())

SPECS2_JUNIT_DEPS = _repoize(specs2_junit_artifact_ids())

DEP_PROVIDERS = [
    "junit_classpath",
    "scalatest_classpath",
    "specs2_classpath",
    "specs2_junit_classpath",
]

def _declare_deps_provider(macro_name, deps_id, deps, visibility):
    label = "%s_%s_provider" % (macro_name, deps_id)
    declare_deps_provider(
        name = label,
        deps_id = deps_id,
        visibility = visibility,
        deps = deps,
    )
    return ":%s" % label

def setup_scala_testing_toolchain(
        name,
        scala_version = SCALA_VERSION,
        junit_classpath = None,
        specs2_classpath = None,
        specs2_junit_classpath = None,
        scalatest_classpath = None,
        visibility = ["//visibility:public"]):
    dep_providers = []

    if junit_classpath != None:
        dep_providers.append(
            _declare_deps_provider(
                name,
                "junit_classpath",
                junit_classpath,
                visibility,
            ),
        )

    if specs2_junit_classpath != None:
        dep_providers.append(
            _declare_deps_provider(
                name,
                "specs2_junit_classpath",
                specs2_junit_classpath,
                visibility,
            ),
        )

    if specs2_classpath != None:
        dep_providers.append(
            _declare_deps_provider(
                name,
                "specs2_classpath",
                specs2_classpath,
                visibility,
            ),
        )

    if scalatest_classpath != None:
        dep_providers.append(
            _declare_deps_provider(
                name,
                "scalatest_classpath",
                scalatest_classpath,
                visibility,
            ),
        )

    scala_testing_toolchain(
        name = name + "_impl",
        dep_providers = dep_providers,
        visibility = visibility,
    )

    native.toolchain(
        name = name,
        toolchain = ":" + name + "_impl",
        toolchain_type = Label("//testing/toolchain:testing_toolchain_type"),
        target_settings = [
            Label(
                "@io_bazel_rules_scala_config//:scala_version" +
                version_suffix(scala_version),
            ),
        ],
        visibility = visibility,
    )
