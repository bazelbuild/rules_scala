load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "compiler",
    srcs = [
        "Compiler.scala",
        "FocusedZipImporter.scala",
    ],
    # util_core is still needed as a dep for older versions of scrooge
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = [
        "//twitter_scrooge:compiler_classpath",
        # Remove this dependency when ScroogeConfig and ScroogeOptionParser are added to the com.twitter.scrooge
        ":option_parser",
    ],
)

# Remove this target when ScroogeConfig and ScroogeOptionParser are added to the com.twitter.scrooge
scala_library(
    name = "option_parser",
    srcs = ["ScroogeOptionParser.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scopt",
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        "//external:io_bazel_rules_scala/dependency/scala/scopt"
    ],
)
