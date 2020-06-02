load(
    "//scala:defs.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)

scala_binary(
    name = "binary",
    srcs = ["binary.scala"],
    main_class = "test.v2.Binary",
    deps = [":library"],
)

scala_library(
    name = "library",
    srcs = ["library.scala"],
    deps = [],
)

scala_test(
    name = "test",
    srcs = ["test.scala"],
    runtime_deps = [
        "@com_novocode_junit_interface",
        # this would normally get exported by scalatest if it was set up as a proper dep
        # instead of just a jar
        "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
        # same, but for junit
        "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
    ],
    deps = [
        ":library",
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        "@io_bazel_rules_scala_junit_junit",
        "@org_scalacheck_scalacheck",
    ],
)
