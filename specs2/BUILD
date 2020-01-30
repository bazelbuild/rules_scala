package(default_visibility = ["//visibility:public"])

java_import(
    name = "specs2",
    jars = [],
    exports = [
        "@io_bazel_rules_scala_org_specs2_specs2_common",
        "@io_bazel_rules_scala_org_specs2_specs2_core",
        "@io_bazel_rules_scala_org_specs2_specs2_fp",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher",
    ],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library", #
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
    ],
)
