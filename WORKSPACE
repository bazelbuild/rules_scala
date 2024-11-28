workspace(name = "io_bazel_rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "rules_python",
    sha256 = "ca77768989a7f311186a29747e3e95c936a41dffac779aff6b443db22290d913",
    strip_prefix = "rules_python-0.36.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.36.0/rules_python-0.36.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config(enable_compiler_dependency_tracking = True)

load("//scala:scala.bzl", "scala_toolchains")

scala_toolchains(fetch_sources = True)

register_toolchains(
    "//testing:testing_toolchain",
    "//scala:unused_dependency_checker_error_toolchain",
    "//test/proto:scalapb_toolchain",
    "@io_bazel_rules_scala_toolchains//...:all",
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")

rules_proto_dependencies()

load("@rules_proto//proto:setup.bzl", "rules_proto_setup")

rules_proto_setup()

load("@rules_proto//proto:toolchains.bzl", "rules_proto_toolchains")

rules_proto_toolchains()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge")

twitter_scrooge()

load("//jmh:jmh.bzl", "jmh_repositories")

jmh_repositories()

load("//scala_proto:scala_proto.bzl", "scala_proto_repositories")

scala_proto_repositories()

load("//scalatest:scalatest.bzl", "scalatest_repositories")

scalatest_repositories()

load("//specs2:specs2_junit.bzl", "specs2_junit_repositories")

specs2_junit_repositories()

load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_default_config", "scalafmt_repositories")

scalafmt_default_config()

scalafmt_repositories()

# needed for the cross repo proto test
local_repository(
    name = "proto_cross_repo_boundary",
    path = "test/proto_cross_repo_boundary/repo",
)

local_repository(
    name = "test_new_local_repo",
    path = "third_party/test/new_local_repo",
)

local_repository(
    name = "example_external_workspace",
    path = "third_party/test/example_external_workspace",
)

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "6dc2da7ab4cf5d7bfc7c949776b1b7c733f05e56edc4bcd9022bb249d2e2a996",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.1/rules_go-v0.39.1.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.39.1/rules_go-v0.39.1.zip",
    ],
)

load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)

go_rules_dependencies()

go_register_toolchains(version = "1.19.5")

http_archive(
    name = "bazelci_rules",
    sha256 = "eca21884e6f66a88c358e580fd67a6b148d30ab57b1680f62a96c00f9bc6a07e",
    strip_prefix = "bazelci_rules-1.0.0",
    url = "https://github.com/bazelbuild/continuous-integration/releases/download/rules-1.0.0/bazelci_rules-1.0.0.tar.gz",
)

load("@bazelci_rules//:rbe_repo.bzl", "rbe_preconfig")

rbe_preconfig(
    name = "rbe_default",
    toolchain = "ubuntu2004-bazel-java11",
)

load("//scala/private/extensions:dev_deps.bzl", "dev_deps_repositories")

dev_deps_repositories()

# Copied from bazel_tools/tools/jdk/remote_java_repository.bzl.
[
    register_toolchains(
        "@remotejdk21_" + platform + "_toolchain_config_repo//:all",
    )
    for platform in [
        "linux",
        "macos",
        "win",
    ]
]

register_toolchains("//test/toolchains:java21_toolchain_definition")
