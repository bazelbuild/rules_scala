"""Gathers defaults for toolchain macros in one place.

Used by both //scala:toolchains.bzl and //scala/extensions:deps.bzl.
"""

load(
    "//scala/scalafmt/toolchain:setup_scalafmt_toolchain.bzl",
    _scalafmt = "TOOLCHAIN_DEFAULTS",
)
load("//scala_proto:toolchains.bzl", _scala_proto = "TOOLCHAIN_DEFAULTS")
load(
    "//twitter_scrooge/toolchain:toolchain.bzl",
    _twitter_scrooge = "TOOLCHAIN_DEFAULTS",
)

TOOLCHAIN_DEFAULTS = {
    "scalafmt": _scalafmt,
    "scala_proto": _scala_proto,
    "twitter_scrooge": _twitter_scrooge,
}
