load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "format",
    srcs = glob(["*.scala"]),
    scala_version = "3.6.2",
    visibility = ["//visibility:public"],
    deps = [
        "@com_softwaremill_common_tagging_3_6_2",
        "@dev_zio_izumi_reflect_3_6_2",
        "@dev_zio_izumi_reflect_thirdparty_boopickle_shaded_3_6_2",
        "@io_bazel_rules_scala_scala_compiler_3_6_2",
        "@io_bazel_rules_scala_scala_tasty_core_3_6_2",
    ],
)
