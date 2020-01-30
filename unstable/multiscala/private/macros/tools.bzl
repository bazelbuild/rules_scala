"""multiscala equivalents to scala/scala.bzl

TBD
"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _configuration = "configuration",
    _versions = "versions",
)
load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")
load(
    "//unstable/multiscala:configuration.bzl",
    _toolchain_label = "toolchain_label",
)

# FIXME: rename
def remove_toolchains(kwargs, version):
    """check and remove toolchain from kwargs; passed explicitly

    Args:
      kwargs: complete set of arguments passed to the macro
      version: scala version being targetted
    Returns:
      New kwargs dict
    """

    kwargs = _dicts.add(kwargs)
    kwargs["scala_suffixes"] = True
    if "toolchains" in kwargs:
        if kwargs["toolchains"] != [_toolchain_label("scala", version["mvn"])]:
            fail([kwargs["toolchains"], [_toolchain_label("scala", version["mvn"])]])
        kwargs.pop("toolchains")
        kwargs["scala_suffixes"] = False
    if "scala" in kwargs:
        kwargs.pop("scala")
    return kwargs

def combine_kwargs(
        kwargs,
        mvn_version):
    """"combine adapted scala depedence list with native dependence list

    Args:
      kwargs: complete set of args passed to macro
      mvn_version: scala version being targetted

    Returns:
      Updated kwargs
    """

    kwargs = _dicts.add(kwargs)

    # print("a", kwargs)
    kwargs = _combine_deps("runtime_deps", kwargs, mvn_version)
    kwargs = _combine_deps("deps", kwargs, mvn_version)
    if kwargs["scala_suffixes"]:
        kwargs["name"] = kwargs["name"] + "_" + mvn_version
    kwargs.pop("scala_deps")
    kwargs.pop("scala_runtime_deps")
    kwargs.pop("scala_suffixes")

    # print("b", kwargs)
    return kwargs

def _combine_deps(
        dep_name,
        kwargs,
        mvn_version):
    kwargs = _dicts.add(kwargs)
    new_deps = kwargs[dep_name][:]
    for dep in kwargs["scala_" + dep_name]:
        if kwargs["scala_suffixes"]:
            new_deps.append(dep + "_" + mvn_version)
        else:
            new_deps.append(dep)
    kwargs[dep_name] = new_deps
    return kwargs

def target_versions(kwargs):
    """return scala versions that should be targetted based on kwargs

    Args:
      kwargs: complete set of args passed to macro

    Returns:
      list of versions that should be targetted
"""
    if "toolchains" in kwargs:
        toolchains = kwargs["toolchains"]
        if len(toolchains) != 1:
            fail("multiple toolchains not supported yet: %s" % toolchains)
        (_, target) = toolchains[0].split(":")
        version = target.split("_")
        version = version[1:]
        version = ".".join(version[:-1])
        return [_configuration["scala"][version]]

    if "scala" in kwargs:
        versions = kwargs["scala"]

        if type(versions) == "NoneType":
            return _versions()

        if type(versions) == "string":
            versions = [versions]

        return [_configuration["scala"][version] for version in versions]

    return _versions()

def maven_install(**kwargs):
    _maven_install(**kwargs)

def scala_maven_install():
    fail()
