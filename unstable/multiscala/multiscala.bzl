"""multiscala equivalents to scala/scala.bzl

TBD
"""

load(":configuration.bzl", _toolchain_label = "toolchain_label")
load(":private/macros/scala_binary.bzl", _scala_binary = "scala_binary")
load(":private/macros/scala_library.bzl", _scala_library = "scala_library")
load(":private/macros/scala_test.bzl", _scala_test = "scala_test")

scala_library = _scala_library
scala_binary = _scala_binary
scala_test = _scala_test
toolchain_label = _toolchain_label
