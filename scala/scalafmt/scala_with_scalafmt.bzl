load(
    "//scala:scala.bzl",
    "make_scala_binary",
    "make_scala_library",
    "make_scala_test",
)
load(
    "//scala/scalafmt:ext.bzl",
    "ext_add_phase_scalafmt",
)

scala_binary = make_scala_binary(ext_add_phase_scalafmt)

scala_library = make_scala_library(ext_add_phase_scalafmt)

scala_test = make_scala_test(ext_add_phase_scalafmt)
