"""multiscala equivalents to scala/scala.bzl

TBD
"""

load(
    "//scala:scala.bzl",
    _scala_binary_rule = "scala_binary",
)
load(
    "//unstable/multiscala:configuration.bzl",
    _toolchain_label = "toolchain_label",
)
load(
    "//unstable/multiscala:private/macros/tools.bzl",
    _combine_kwargs = "combine_kwargs",
    _remove_toolchains = "remove_toolchains",
    _target_versions = "target_versions",
)

_binary_suffixes = ["", "_deploy.jar"]

def _create_scala_binary(version, name, **kwargs):
    target_name = name + "_" + version["mvn"]
    _remove_toolchains(kwargs, version)
    _combine_kwargs(kwargs, version["mvn"])
    _scala_binary_rule(
        name = target_name,
        toolchains = [_toolchain_label("scala", version["mvn"])],
        **kwargs
    )
    if version["default"]:
        for suffix in _binary_suffixes:
            native.alias(name = name + suffix, actual = target_name + suffix)

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
    kwargs.update(
        deps = scala_deps,
        runtime_deps = scala_runtime_deps,
        scala_deps = scala_deps,
        scala_runtime_deps = scala_runtime_deps,
    )

    for version in _target_versions(kwargs):
        _create_scala_binary(version, **kwargs)
