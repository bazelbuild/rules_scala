# Test targets for test/shell/test_twitter_scrooge_toolchains.sh.
# Targets adapted from //test/src/main/scala/scalarules/test/twitter_scrooge.
load("@rules_scala//scala:scala.bzl", "scala_library")
load("@rules_scala//thrift:thrift.bzl", "thrift_library")
load(
    "@rules_scala//twitter_scrooge/toolchain:toolchain.bzl",
    "setup_scrooge_toolchain",
)
load(
    "@rules_scala//twitter_scrooge:twitter_scrooge.bzl",
    "scrooge_scala_library",
)

# When using `setup_scrooge_toolchain` with all its dependencies specified, you
# don't need to instantiate the builtin toolchain. In that case, make sure to
# register your custom toolchain via `register_toolchains` in `MODULE.bazel` or
# `WORKSPACE`. See the comments in those files for further details.
#
# It's OK to remove any of these overrides in order to use the builtin defaults
# for those dependencies instead. However, in that case, you _must_ instantiate
# the default `twitter_scrooge` toolchain in `MODULE.bazel` or `WORKSPACE`,
# without the corresponding dependency overrides. This allows `rules_scala` to
# generate the necessary builtin dependency repositories, even if you don't use
# the default toolchain.
#
# However, if you remove the `scrooge_generator` override, the toolchain will
# also depend on the builtin `mustache` and `scopt` repos. You will need to
# remove the `mustache` and `scopt` overrides, too, to use the builtin repos
# instead.
setup_scrooge_toolchain(
    name = "toolchain_from_build_file",
    javax_annotation_api = "@maven//:javax_annotation_javax_annotation_api",
    libthrift = "@maven//:org_apache_thrift_libthrift",
    mustache = "@maven//:com_github_spullara_mustache_java_compiler",
    scopt = "@maven//:com_github_scopt_scopt_2_12",
    scrooge_core = "@maven//:com_twitter_scrooge_core_2_12",
    scrooge_generator = "@maven//:com_twitter_scrooge_generator_2_12",
    util_core = "@maven//:com_twitter_util_core_2_12",
    util_logging = "@maven//:com_twitter_util_logging_2_12",
)

scala_library(
    name = "justscrooge",
    srcs = ["JustScrooge.scala"],
    exports = [":scrooge"],
    deps = [":scrooge"],
)

scrooge_scala_library(
    name = "scrooge",
    visibility = ["//visibility:public"],
    deps = [":thrift"],
)

thrift_library(
    name = "thrift",
    srcs = ["Thrift1.thrift"],
    visibility = ["//visibility:public"],
    deps = [":thrift2"],
)

thrift_library(
    name = "thrift2",
    srcs = ["Thrift2.thrift"],
    visibility = ["//visibility:public"],
)
