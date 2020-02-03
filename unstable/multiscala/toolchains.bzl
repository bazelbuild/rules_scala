"""create toolchains required by configuration"""

load(
    "@io_bazel_rules_scala//scala:scala_toolchain.bzl",
    _scala_toolchain_rule = "scala_toolchain",
)
load(
    "@io_bazel_rules_scala//scala:bootstrap_toolchain.bzl",
    _bootstrap_toolchain_rule = "bootstrap_toolchain",
)
load(
    "@io_bazel_rules_scala//scala:scala_test_toolchain.bzl",
    _scala_test_toolchain_rule = "scala_test_toolchain",
)
load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _versions = "versions",
)
load(
    "@rules_jvm_external//:defs.bzl",
    _artifact = "artifact",
)
load(
    ":configuration.bzl",
    _native_toolchain_label = "native_toolchain_label",
    _scalac_label = "scalac_label",
    _scalatest_reporter_label = "scalatest_reporter_label",
    _scalatest_runner_label = "scalatest_runner_label",
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
    _create_scala_test_toolchain(version)

def _create_bootstrap_toolchain(version):
    mvn = version["mvn"]

    name = _toolchain_label("bootstrap", mvn, in_package = True)

    attrs = {}

    attrs["name"] = name
    attrs["visibility"] = ["//visibility:public"]

    repository_name = "io_bazel_rules_scala_" + version["scala"].replace(".", "_")

    library = _artifact("org.scala-lang:scala-library", repository_name = repository_name)
    compiler = _artifact("org.scala-lang:scala-compiler", repository_name = repository_name)
    reflect = _artifact("org.scala-lang:scala-reflect", repository_name = repository_name)
    attrs["classpath"] = [library, reflect]
    attrs["macro_classpath"] = [library, reflect]
    attrs["repl_classpath"] = [compiler, library, reflect]

    _bootstrap_toolchain_rule(**attrs)

    native.toolchain(
        name = _native_toolchain_label("bootstrap", version["mvn"], in_package = True),
        toolchain = name,
        toolchain_type = "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
        visibility = ["//visibility:public"],
    )

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
    attrs["scalac"] = _scalac_label(version["mvn"])

    _scala_toolchain_rule(**attrs)

    native.toolchain(
        name = _native_toolchain_label("scala", version["mvn"], in_package = True),
        toolchain = name,
        toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
        visibility = ["//visibility:public"],
    )

def _scala_artifact(version, scala_coordinate):
    components = scala_coordinate.split(":")
    if len(components) == 2:
        components.append("{" + components[1] + "}")
    (org, artifact, artifact_version) = components
    java_coordinate = ":".join([org, artifact + "_" + version["scala"], artifact_version])
    return java_coordinate.format(**version)

def _create_scala_test_toolchain(version):
    mvn = version["mvn"]

    name = _toolchain_label("scala_test", mvn, in_package = True)

    attrs = {}

    attrs["name"] = name
    attrs["visibility"] = ["//visibility:public"]

    repository_name = "io_bazel_rules_scala_" + version["scala"].replace(".", "_")

    scalatest = _artifact("org.scalatest:scalatest_" + version["mvn"], repository_name = repository_name)
    scalactic = _artifact("org.scalactic:scalactic_" + version["mvn"], repository_name = repository_name)
    attrs["deps"] = [scalatest, scalactic]
    attrs["reporter"] = _scalatest_reporter_label(version["mvn"])
    attrs["runner"] = _scalatest_runner_label(version["mvn"])

    _scala_test_toolchain_rule(**attrs)

    native.toolchain(
        name = _native_toolchain_label("scala_test", version["mvn"], in_package = True),
        toolchain = name,
        toolchain_type = "@io_bazel_rules_scala//scala:scala_test_toolchain_type",
        visibility = ["//visibility:public"],
    )
