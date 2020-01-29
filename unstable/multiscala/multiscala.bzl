"""multiscala equivalents to scala/scala.bzl

TBD
"""

load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _configuration = "configuration",
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

def _remove_toolchains(kwargs, version):
    if "toolchains" in kwargs:
        if kwargs["toolchains"] != [_toolchain_label("scala", version["mvn"])]:
            fail([kwargs["toolchains"], [_toolchain_label("scala", version["mvn"])]])
        kwargs.pop("toolchains")

def _create_scala_library(version, name, **kwargs):
    target_name = name + "_" + version["mvn"]
    _remove_toolchains(kwargs, version)
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
    _remove_toolchains(kwargs, version)
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
    _remove_toolchains(kwargs, version)
    kwargs["name"] = target_name
    kwargs["toolchains"] = [_toolchain_label("scala", version["mvn"])]
    _combine_kwargs(kwargs, version["mvn"])
    print(kwargs)
    _scala_test_rule(**kwargs)
    if version["default"]:
        native.alias(name = name, actual = target_name)

def _combine_kwargs(
        kwargs,
        mvn_version):
    kwargs["runtime_deps"] = _combine_deps("runtime_deps", kwargs, mvn_version)
    kwargs["deps"] = _combine_deps("deps", kwargs, mvn_version)
    kwargs.pop("scala_deps")
    kwargs.pop("scala_runtime_deps")
    return kwargs

def _combine_deps(
        dep_name,
        kwargs,
        mvn_version):
    added_deps = []
    fail()  # if not
    name = name + "_" + mvn_version if mvn_version else name
    fail()  # prefix =
    for dep in kwargs["scala_" + dep_name]:
        fail()
    return fail()  # kwargs[dep_name"deps"] + added_deps

def _target_versions(kwargs):
    if "toolchains" in kwargs:
        toolchains = kwargs["toolchains"]
        if len(toolchains) != 1:
            fail("multiple toolchains not supported yet: %s" % toolchains)
        (_, target) = toolchains[0].split(":")
        version = target.split("_")
        version = version[1:]
        version = ".".join(version[:-1])
        return [_configuration["scala"][version]]
    else:
        return _versions()

def scala_library(
        scala_deps = [],
        scala_runtime_deps = [],
        **kwargs):
    """create a multi-scala library

    Args:
      scala_deps: deps that require scala version naming
      scala_runtime_deps: deps that require scala version naming
      **kwargs: standard scala_library arguments
    """

    for version in _target_versions(kwargs):
        _create_scala_library(version, **kwargs)

def scala_binary(
        scala_deps = [],
        scala_runtime_deps = [],
        **kwargs):
    """create a multi-scala binary

    Args:
      scala_deps: deps that require scala version naming
      scala_runtime_deps: deps that require scala version naming
      **kwargs: standard scala_binary arguments
    """

    for version in _target_versions(kwargs):
        _create_scala_binary(version, **kwargs)

def scala_test(
        scala_deps = [],
        scala_runtime_deps = [],
        **kwargs):
    """create a multi-scala test

    Args:
      scala_deps: deps that require scala version naming
      scala_runtime_deps: deps that require scala version naming
      **kwargs: standard scala_test arguments
    """

    for version in _target_versions(kwargs):
        _create_scala_test(version, **kwargs)
