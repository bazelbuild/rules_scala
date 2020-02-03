"""multiscala equivalents to scala/scala.bzl

TBD
"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "//unstable/multiscala:configuration.bzl",
    _toolchain_label = "toolchain_label",
)
load(
    "@//scala/private:rules/scala_binary.bzl",
    _uniscala_scala_binary = "scala_binary",
)
load(
    "//unstable/multiscala:private/macros/tools.bzl",
    _combine_kwargs = "combine_kwargs",
    _remove_toolchains = "remove_toolchains",
    _target_versions = "target_versions",
)

_binary_suffixes = ["", "_deploy.jar"]

def _create_scala_binary(version, **kwargs):
    kwargs = _remove_toolchains(kwargs, version)
    kwargs = _combine_kwargs(kwargs, version["mvn"])
    kwargs.update(
        toolchains = [_toolchain_label("scala", version["mvn"])],
    )

    # print(kwargs)
    _uniscala_scala_binary(**kwargs)

def scala_binary(
        scala_deps = [],
        scala_runtime_deps = [],
        deps = [],
        runtime_deps = [],
        scala = None,
        **kwargs):
    """create a multi-scala binary

    Args:
      scala_deps: deps that require scala version naming
      scala_runtime_deps: deps that require scala version naming
      deps: deps that do not require scala version changes
      runtime_deps: runtime_deps that do not require scala version changes
      scala: verisons of scala to build for
      **kwargs: standard scala_binary arguments
    """
    kwargs = _dicts.add(kwargs)
    kwargs.update(
        scala = scala,
        deps = deps,
        runtime_deps = runtime_deps,
        scala_deps = scala_deps,
        scala_runtime_deps = scala_runtime_deps,
    )

    for version in _target_versions(kwargs):
        _create_scala_binary(version, **kwargs)
