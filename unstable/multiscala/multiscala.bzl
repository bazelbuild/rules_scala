"""multiscala equivalents to scala/scala.bzl

TBD
"""

load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _versions = "versions",
)
load(
    "//scala:scala.bzl",
    _scala_binary_rule = "scala_binary",
    _scala_library_rule = "scala_library",
    _scala_test_rule = "scala_test",
)
load(
    ":configuration.bzl",
    _toolchain_label = "toolchain_label",
)

def _create_scala_library(version, name, **kwargs):
    target_name = name + "_" + version["mvn"]
    _scala_library_rule(
        name = target_name,
        toolchains = [_toolchain_label("scala", version["mvn"])],
        **kwargs
    )
    if version["default"]:
        native.alias(name = name, actual = target_name)

_binary_suffixes = ["", "_deploy.jar"]

def _create_scala_binary(version, name, **kwargs):
    target_name = name + "_" + version["mvn"]
    _scala_binary_rule(
        name = target_name,
        toolchains = [_toolchain_label("scala", version["mvn"])],
        **kwargs
    )
    if version["default"]:
        for suffix in _binary_suffixes:
            native.alias(name = name + suffix, actual = target_name + suffix)

def _create_scala_test(version, name, **kwargs):
    target_name = name + "_" + version["mvn"]
    _scala_test_rule(
        name = target_name,
        toolchains = [_toolchain_label("scala", version["mvn"])],
        **kwargs
    )
    if version["default"]:
        native.alias(name = name, actual = target_name)

def scala_library(**kwargs):
    """create a multi-scala library

    Args:
      **kwargs: standard scala_library arguments
    """

    versions = _versions()
    if "toolchains" in kwargs:
        _scala_library_rule(**kwargs)
    else:
        for version in versions:
            _create_scala_library(version, **kwargs)

def scala_binary(**kwargs):
    """create a multi-scala binary

    Args:
      **kwargs: standard scala_binary arguments
    """

    versions = _versions()
    if "toolchains" in kwargs:
        _scala_binary_rule(**kwargs)
    else:
        for version in versions:
            _create_scala_binary(version, **kwargs)

def scala_test(**kwargs):
    """create a multi-scala test

    Args:
      **kwargs: standard scala_test arguments
    """

    versions = _versions()
    if "toolchains" in kwargs:
        _scala_test_rule(**kwargs)
    else:
        for version in versions:
            _create_scala_test(version, **kwargs)
