load(
    "//scala:advanced_usage/scala.bzl",
    "make_scala_binary",
    "make_scala_library",
#    "make_scala_test",
)
load(
    "//scala/bloop:ext.bzl",
    "ext_add_phase_bloop",
)

scala_binary = make_scala_binary(ext_add_phase_bloop)

scala_library = make_scala_library(ext_add_phase_bloop)

#scala_test = make_scala_test(ext_add_phase_bloop)
