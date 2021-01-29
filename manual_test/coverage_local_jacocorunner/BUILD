load("//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "local_jacocorunner_toolchain_impl",
    jacocorunner = ":local_jacocorunner",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_jacocorunner_scala_toolchain",
    toolchain = "local_jacocorunner_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "local_jacocorunner",
    srcs = ["JacocoCoverage_jarjar_deploy.jar"],
)
