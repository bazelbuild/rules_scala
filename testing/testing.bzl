load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

_SPECS2_DEPS = [
    "@io_bazel_rules_scala_org_specs2_specs2_common",
    "@io_bazel_rules_scala_org_specs2_specs2_core",
    "@io_bazel_rules_scala_org_specs2_specs2_fp",
    "@io_bazel_rules_scala_org_specs2_specs2_matcher",
]

_SPECS2_JUNIT_DEPS = [
    "@io_bazel_rules_scala_org_specs2_specs2_junit",
]

_JUNIT_DEPS = [
    "@io_bazel_rules_scala_junit_junit",
    "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
]

_SCALATEST_DEPS = [
    "@io_bazel_rules_scala_scalactic",
    "@io_bazel_rules_scala_scalatest",
    "@io_bazel_rules_scala_scalatest_compatible",
    "@io_bazel_rules_scala_scalatest_core",
    "@io_bazel_rules_scala_scalatest_featurespec",
    "@io_bazel_rules_scala_scalatest_flatspec",
    "@io_bazel_rules_scala_scalatest_freespec",
    "@io_bazel_rules_scala_scalatest_funspec",
    "@io_bazel_rules_scala_scalatest_funsuite",
    "@io_bazel_rules_scala_scalatest_matchers_core",
    "@io_bazel_rules_scala_scalatest_mustmatchers",
    "@io_bazel_rules_scala_scalatest_shouldmatchers",
]

def _declare_deps_provider(macro_name, deps_id, deps, visibility):
    label = "%s_%s_provider" % (macro_name, deps_id)
    declare_deps_provider(
        name = label,
        deps_id = deps_id,
        visibility = visibility,
        deps = deps,
    )
    return label

def setup_scala_testing_toolchain(
        name,
        scala_version = None,
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
        toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
        visibility = visibility,
    )

def setup_scalatest_toolchains():
    for scala_version in SCALA_VERSIONS:
        setup_scala_testing_toolchain(
            name = "scalatest_toolchain" + version_suffix(scala_version),
            scala_version = scala_version,
            scalatest_classpath = _scalatest_deps(scala_version),
            visibility = ["//visibility:public"],
        )
    setup_scala_testing_toolchain(
        name = "testing_toolchain",
        junit_classpath = _JUNIT_DEPS,
        scalatest_classpath = _scalatest_deps(),
        specs2_classpath = _SPECS2_DEPS,
        specs2_junit_classpath = _SPECS2_JUNIT_DEPS,
        visibility = ["//visibility:public"],
    )
    setup_scala_testing_toolchain(
        name = "specs2_junit_toolchain",
        junit_classpath = _JUNIT_DEPS,
        specs2_classpath = _SPECS2_DEPS,
        specs2_junit_classpath = _SPECS2_JUNIT_DEPS,
        visibility = ["//visibility:public"],
    )
    setup_scala_testing_toolchain(
        name = "junit_toolchain",
        junit_classpath = _JUNIT_DEPS,
        visibility = ["//visibility:public"],
    )

def _scalatest_deps(scala_version = SCALA_VERSION):
    suffix = version_suffix(scala_version)
    return [dep + suffix for dep in _SCALATEST_DEPS]
