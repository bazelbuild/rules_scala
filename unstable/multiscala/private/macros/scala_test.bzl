"""multiscala equivalents to scala/scala.bzl

TBD
"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_test.bzl",
    _uniscala_scala_test = "scala_test",
)
load(
    "//unstable/multiscala:configuration.bzl",
    _toolchain_label = "toolchain_label",
)
load(
   "//unstable/multiscala/private:macros/tools.bzl",
    _combine_kwargs = "combine_kwargs",
    _remove_toolchains = "remove_toolchains",
    _target_versions = "target_versions",
)

def _create_scala_test(version, **kwargs):
    kwargs = _remove_toolchains(kwargs, version)
    kwargs["toolchains"] = [
        _toolchain_label("scala", version["mvn"]),
        _toolchain_label("scala_test", version["mvn"]),
    ]
    kwargs = _combine_kwargs(kwargs, version["mvn"])
    _uniscala_scala_test(**kwargs)

def scala_test(
        scala_deps = [],
        scala_runtime_deps = [],
        deps = [],
        runtime_deps = [],
        scala = None,
        **kwargs):
    """create a multi-scala test

    Args:
      scala_deps: deps that require scala version naming
      scala_runtime_deps: deps that require scala version naming
      deps: deps that do not require scala version changes
      runtime_deps: runtime_deps that do not require scala version changes
      scala: verisons of scala to build for
      **kwargs: standard scala_test arguments
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
        _create_scala_test(version, **kwargs)
