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

_build_tools_release = "5.1.0"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "e3bb0dc8b0274ea1aca75f1f8c0c835adbe589708ea89bf698069d0790701ea3",
    strip_prefix = "buildtools-%s" % _build_tools_release,
    url = "https://github.com/bazelbuild/buildtools/archive/%s.tar.gz" % _build_tools_release,
)

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config(enable_compiler_dependency_tracking = True)

load("//scala:scala.bzl", "rules_scala_setup", "rules_scala_toolchain_deps_repositories")

rules_scala_setup()

rules_scala_toolchain_deps_repositories(fetch_sources = True)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

# Declares @com_google_protobuf//:protoc pointing to released binary
# This should stop building protoc during bazel build
# See https://github.com/bazelbuild/rules_proto/pull/36
rules_proto_dependencies()

rules_proto_toolchains()

load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
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

register_toolchains("//testing:testing_toolchain")

load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_default_config", "scalafmt_repositories")

scalafmt_default_config()

scalafmt_repositories()

MAVEN_SERVER_URLS = default_maven_server_urls()

# needed for the cross repo proto test
load("//test/proto_cross_repo_boundary:repo.bzl", "proto_cross_repo_boundary_repository")

proto_cross_repo_boundary_repository()

new_local_repository(
    name = "test_new_local_repo",
    build_file_content =
        """
filegroup(
    name = "data",
    srcs = glob(["**/*.txt"]),
    visibility = ["//visibility:public"],
)
""",
    path = "third_party/test/new_local_repo",
)

local_repository(
    name = "example_external_workspace",
    path = "third_party/test/example_external_workspace",
)

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_unused_deps_toolchains")

scala_register_unused_deps_toolchains()

register_toolchains("@io_bazel_rules_scala//test/proto:scalapb_toolchain")

load("//scala:scala_maven_import_external.bzl", "java_import_external")

# bazel's java_import_external has been altered in rules_scala to be a macro based on jvm_import_external
# in order to allow for other jvm-language imports (e.g. scala_import)
# the 3rd-party dependency below is using the java_import_external macro
# in order to make sure no regression with the original java_import_external
java_import_external(
    name = "org_apache_commons_commons_lang_3_5_without_file",
    generated_linkable_rule_name = "linkable_org_apache_commons_commons_lang_3_5_without_file",
    jar_sha256 = "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    jar_urls = ["https://repo.maven.apache.org/maven2/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar"],
    licenses = ["notice"],  # Apache 2.0
    neverlink = True,
    testonly_ = True,
)

## Linting

load("//private:format.bzl", "format_repositories")

format_repositories()

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

# Explicitly pull in a different (newer) version of rules_java for remote jdks
rules_java_extra_version = "5.1.0"

rules_java_extra_sha = "d974a2d6e1a534856d1b60ad6a15e57f3970d8596fbb0bb17b9ee26ca209332a"

rules_java_extra_url = "https://github.com/bazelbuild/rules_java/releases/download/{}/rules_java-{}.tar.gz".format(rules_java_extra_version, rules_java_extra_version)

http_archive(
    name = "rules_java_extra",
    sha256 = rules_java_extra_sha,
    url = rules_java_extra_url,
)

load("@rules_java//java:repositories.bzl", "remote_jdk8_repos")

# We need to select based on platform when we use these
# https://github.com/bazelbuild/bazel/issues/11655
remote_jdk8_repos()

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

load("//third_party/repositories:repositories.bzl", "repositories")

repositories(
    fetch_sources = False,
    for_artifact_ids = [
        # test adding a scala jar:
        "com_twitter__scalding_date",
        # test of strict deps (scalac plugin UT + E2E)
        "com_google_guava_guava_21_0_with_file",
        "com_github_jnr_jffi_native",
        "org_apache_commons_commons_lang_3_5",
        "com_google_guava_guava_21_0",
        # test of import external
        # scala maven import external decodes maven artifacts to its parts
        # (group id, artifact id, packaging, version and classifier). To make sure
        # the decoding and then the download url composition are working the artifact example
        # must contain all the different parts and sha256s so the downloaded content will be
        # validated against it
        "org_springframework_spring_core",
        "org_springframework_spring_tx",
        "org_typelevel_kind_projector",
        # For testing that we don't include sources jars to the classpath
        "org_typelevel__cats_core",
    ],
    maven_servers = MAVEN_SERVER_URLS,
)

load("//test/toolchains:jdk.bzl", "remote_jdk21_repositories", "remote_jdk21_toolchains")

remote_jdk21_repositories()

remote_jdk21_toolchains()
