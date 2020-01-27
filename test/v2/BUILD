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
    deps = [
        ":library",
	"@org_scalacheck_scalacheck//:org_scalacheck_scalacheck",
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
    ],
    runtime_deps = [
        # this would normally get exported by scalatest if it was set up as a proper dep
	# instead of just a jar
	"//external:io_bazel_rules_scala/dependency/scala/scala_xml",
    ]
)
