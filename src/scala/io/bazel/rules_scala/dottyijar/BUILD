load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping", "scala_specs2_junit_test")
load("@rules_java//java:defs.bzl", "java_binary")

scala_library_for_plugin_bootstrapping(
    name = "dottyijar-library",
    srcs = glob(
        ["*.scala"],
        exclude = ["*.spec.scala"],
    ),
    scala_version = "3.6.2",
    visibility = ["//visibility:public"],
    deps = [
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty",
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty/format",
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty/numeric",
        "@dev_zio_izumi_reflect_3_6_2",
    ],
)

# TODO: Eventually, we should make a bootstrapping toolchain so we don't have to create a `*_for_plugin_bootstrapping` equivalent for each Scala rule.
java_binary(
    name = "dottyijar",
    main_class = "io.bazel.rules_scala.dottyijar.DottyIjar",
    visibility = ["//visibility:public"],
    runtime_deps = [":dottyijar-library"],
)

scala_specs2_junit_test(
    name = "specs",
    srcs = glob(["*.spec.scala"]),
    scala_version = "3.6.2",
    suffixes = ["Spec"],
    deps = [
        ":dottyijar-library",
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty:test",
        "@io_bazel_rules_scala_org_specs2_specs2_common_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_core_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_junit",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher_3_6_2",
        "@io_bazel_rules_scala_scala_tasty_inspector_3_6_2",
    ],
)
