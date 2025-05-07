workspace(name = "rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//scala:latest_deps.bzl", "rules_scala_dependencies")

rules_scala_dependencies()

# Only include the next two statements if using
# `--incompatible_enable_proto_toolchain_resolution`.
load("@platforms//host:extension.bzl", "host_platform_repo")

# Instantiates the `@host_platform` repo to work around:
# - https://github.com/bazelbuild/bazel/issues/22558
host_platform_repo(name = "host_platform")

# This is optional, but still safe to include even when not using
# `--incompatible_enable_proto_toolchain_resolution`. Requires invoking the
# `scala_protoc_toolchains` repo rule. Register this toolchain before any
# others.
register_toolchains("@rules_scala_protoc_toolchains//...:all")

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")

rules_java_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "rules_python",
    sha256 = "a837679f1382f26968c1ee6f839c7daf9079aa53128069a1f2815decaa637304",
    strip_prefix = "rules_python-1.4.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/1.4.0/rules_python-1.4.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@rules_java//java:repositories.bzl", "rules_java_toolchains")

rules_java_toolchains()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")

rules_proto_dependencies()

load("@rules_proto//proto:setup.bzl", "rules_proto_setup")

rules_proto_setup()

load("@rules_proto//proto:toolchains.bzl", "rules_proto_toolchains")

rules_proto_toolchains()

# Include this after loading `platforms`, `com_google_protobuf`, and
# `rules_proto` to enable the `//protoc` precompiled protocol compiler
# toolchains.
load("@rules_scala//protoc:toolchains.bzl", "scala_protoc_toolchains")

# This name can be anything, but we recommend `rules_scala_protoc_toolchains`.
scala_protoc_toolchains(name = "rules_scala_protoc_toolchains")

load("//:scala_config.bzl", "scala_config")

scala_config(enable_compiler_dependency_tracking = True)

load("//scala:toolchains.bzl", "scala_register_toolchains", "scala_toolchains")

scala_toolchains(
    fetch_sources = True,
    jmh = True,
    junit = True,
    scala_proto = True,
    scalafmt = True,
    scalatest = True,
    specs2 = True,
    twitter_scrooge = True,
)

register_toolchains(
    "//scala:unused_dependency_checker_error_toolchain",
    "//test/proto:scalapb_toolchain",
)

scala_register_toolchains()

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
    sha256 = "f2d15bea3e241aa0e3a90fb17a82e6a8ab12214789f6aeddd53b8d04316d2b7c",
    urls = [
        "https://mirror.bazel.build/github.com/bazel-contrib/rules_go/releases/download/v0.54.0/rules_go-v0.54.0.zip",
        "https://github.com/bazel-contrib/rules_go/releases/download/v0.54.0/rules_go-v0.54.0.zip",
    ],
)

load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)

go_rules_dependencies()

go_register_toolchains(version = "1.24.2")

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

register_toolchains("//test/toolchains:java21_toolchain_definition")
