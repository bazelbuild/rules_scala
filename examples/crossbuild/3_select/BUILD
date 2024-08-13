load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")
load("@io_bazel_rules_scala//scala:scala_cross_version_select.bzl", "select_for_scala_version")

# Here we demonstrate how to provide distinct source files depending on the version requested

# Trying to provide library that works with all Scala versions:
scala_library(
    name = "lib",
    srcs = select_for_scala_version(
        before_3 = [
            # for Scala version < 3
            "lib2.scala",
        ],
        since_3 = [
            # for 3 ≤ Scala version
            "lib3.scala",
        ],
    ),
)

scala_binary(
    name = "bin2",
    srcs = ["bin.scala"],
    main_class = "B",
    scala_version = "2.13.14",
    deps = [":lib"],
)

scala_binary(
    name = "bin3",
    srcs = ["bin.scala"],
    main_class = "B",
    scala_version = "3.4.2",
    deps = [":lib"],
)
