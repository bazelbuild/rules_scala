"""create toolchains required by configuration"""

load(
    "@io_bazel_rules_scala//scala:scala_toolchain.bzl",
    _scala_toolchain_rule = "scala_toolchain",
)
load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _versions = "versions",
)
load(
    ":configuration.bzl",
    _native_toolchain_label = "native_toolchain_label",
    _toolchain_label = "toolchain_label",
)

def create_toolchains():
    _create_all_toolchains()

def _create_all_toolchains():
    for version in _versions():
        _create_version_toolchains(version)

def _create_version_toolchains(version):
    _create_bootstrap_toolchain(version)
    _create_scala_toolchain(version)
    _create_scalatest_toolchain(version)

def _create_bootstrap_toolchain(version):
    pass

_scala_toolchain_attrs = [
    "scalacopts",
    "scalac_provider_attr",
    "unused_dependency_checker_mode",
    "plus_one_deps_mode",
    "enable_code_coverage_aspect",
    "scalac_jvm_flags",
    "scala_test_jvm_flags",
]

def _create_scala_toolchain(version):
    name = _toolchain_label("scala", version["mvn"], in_package = True)

    attrs = {}

    for attr in _scala_toolchain_attrs:
        if attr in version["scala_toolchain"]:
            attrs[attr] = version["scala_toolchain"][attr]

    attrs["name"] = name
    attrs["visibility"] = ["//visibility:public"]

    _scala_toolchain_rule(**attrs)

    native.toolchain(
        name = _native_toolchain_label("scala", version["mvn"], in_package = True),
        toolchain = name,
        toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
        visibility = ["//visibility:public"],
    )

def _create_scalatest_toolchain(version):
    pass
