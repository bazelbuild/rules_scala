load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")

# Here we demonstrate how scala_version is propagated through deps.

# This one will always be compiled by 2.11 compiler:
scala_library(
    name = "lib211",
    srcs = ["lib.scala"],
    scala_version = "2.11.12",
)

# This one will be compiled by 3.3 compiler (unless requested otherwise)
scala_library(
    name = "lib",
    srcs = ["lib_default.scala"],
)

scala_binary(
    name = "bin213",
    srcs = ["bin.scala"],  # compiled with 2.13 (as per `scala_version`)
    main_class = "C",
    scala_version = "2.13.14",
    deps = [
        ":lib",  # compiled 2.13 (as per `scala_version`)
        ":lib211",  # compiled with 2.11 (that target overrides version)
    ],
)

scala_binary(
    name = "bin33",
    srcs = ["bin.scala"],  # compiled with 3.3 (the default)
    main_class = "C",
    deps = [
        ":lib",  # compiled with 3.3 (default)
        ":lib211",  # compiled with 2.11 (that target overrides version)
    ],
)
