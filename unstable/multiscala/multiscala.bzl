"""multiscala equivalents to scala/scala.bzl

TBD
"""

load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _configuration = "configuration",
)
load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(":configuration.bzl", _toolchain_label = "toolchain_label")
load("//unstable/multiscala/private:macros/scala_binary.bzl", _scala_binary = "scala_binary")
load("//unstable/multiscala/private:macros/scala_library.bzl", _scala_library = "scala_library")
load("//unstable/multiscala/private:macros/scala_test.bzl", _scala_test = "scala_test")

# def scala_library(**kwargs): _scala_library(_configuration(), **kwargs)
# def scala_binary(**kwargs): _scala_binary(_configuration(), **kwargs)
# def scala_test(**kwargs):
#     _scala_test(**_dicts.add(kwargs, configuration = _configuration()))

toolchain_label = _toolchain_label
