load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")

# Here we demonstrate the simplest case,
# single binary, test or library for which we set a specific version or use the default one:

# This one will be compiled by 2.11 compiler:
scala_library(
    name = "lib211",
    srcs = ["lib.scala"],
    scala_version = "2.11.12",
)

# This one will be compiled by 2.13 compiler:
scala_test(
    name = "test213",
    srcs = ["test.scala"],
    scala_version = "2.13.15",
)

# This one will be compiled by 3.3 compiler (the default one):
scala_binary(
    name = "bin33",
    srcs = ["bin.scala"],
    main_class = "X",
)
