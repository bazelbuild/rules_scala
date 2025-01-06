load("//scala:scala.bzl", "scala_library", "scala_library_for_plugin_bootstrapping", "scala_specs2_junit_test")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

scala_library_for_plugin_bootstrapping(
    name = "tasty",
    srcs = glob(
        ["*.scala"],
        exclude = [
            "*.spec.scala",
            "*.test.scala",
        ],
    ),
    scala_version = "3.6.2",
    visibility = ["//visibility:public"],
    deps = [
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty/format",
        "@com_softwaremill_common_tagging_3_6_2",
        "@dev_zio_izumi_reflect_3_6_2",
        "@dev_zio_izumi_reflect_thirdparty_boopickle_shaded_3_6_2",
        "@io_bazel_rules_scala_scala_compiler_3_6_2",
        "@io_bazel_rules_scala_scala_tasty_core_3_6_2",
    ],
)

copy_file(
    name = "scala3-compiler-jar",
    src = "@io_bazel_rules_scala_scala_compiler_3_6_2//:scala3-compiler_3-3.6.2.jar",
    out = "scala3-compiler.jar",
)

scala_library(
    name = "test",
    testonly = True,
    srcs = glob(["*.test.scala"]),
    resource_strip_prefix = package_name(),
    resources = [":scala3-compiler-jar"],
    scala_version = "3.6.2",
    visibility = ["//visibility:public"],
    deps = [
        "@commons_io_commons_io_3_6_2",
        "@io_bazel_rules_scala_junit_junit",
        "@io_bazel_rules_scala_org_specs2_specs2_common_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_core_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_junit",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher_3_6_2",
    ],
)

scala_specs2_junit_test(
    name = "specs",
    srcs = glob(["*.spec.scala"]),
    jvm_flags = ["-DDEBUG_TASTYFORMAT=true"],
    scala_version = "3.6.2",
    suffixes = ["Spec"],
    deps = [
        ":tasty",
        ":test",
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty/format",
        "@io_bazel_rules_scala_org_specs2_specs2_common_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_core_3_6_2",
        "@io_bazel_rules_scala_org_specs2_specs2_junit",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher_3_6_2",
        "@io_bazel_rules_scala_scala_compiler_3_6_2",
    ],
)
