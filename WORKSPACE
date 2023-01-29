workspace(name = "io_bazel_rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

skylib_version = "1.0.3"

http_archive(
    name = "bazel_skylib",
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    type = "tar.gz",
    url = "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib-{}.tar.gz".format(skylib_version, skylib_version),
)

_build_tools_release = "3.5.0"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "a02ba93b96a8151b5d8d3466580f6c1f7e77212c4eb181cba53eb2cae7752a23",
    strip_prefix = "buildtools-%s" % _build_tools_release,
    url = "https://github.com/bazelbuild/buildtools/archive/%s.tar.gz" % _build_tools_release,
)

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config()

load("//scala/semanticdb:semanticdb_repositories.bzl", "semanticdb_repositories")
semanticdb_repositories()

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
    name = "strip_resource_external_workspace",
    path = "third_party/test/strip_resource_external_workspace",
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
    sha256 = "d1ffd055969c8f8d431e2d439813e42326961d0942bdf734d2c95dc30c369566",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.24.5/rules_go-v0.24.5.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.24.5/rules_go-v0.24.5.tar.gz",
    ],
)

load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)

go_rules_dependencies()

go_register_toolchains()

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

bazel_toolchains_version = "4.1.0"

http_archive(
    name = "bazel_toolchains",
    sha256 = "179ec02f809e86abf56356d8898c8bd74069f1bd7c56044050c2cd3d79d0e024",
    strip_prefix = "bazel-toolchains-%s" % bazel_toolchains_version,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/releases/download/%s/bazel-toolchains-%s.tar.gz" % (bazel_toolchains_version, bazel_toolchains_version),
        "https://github.com/bazelbuild/bazel-toolchains/releases/download/%s/bazel-toolchains-%s.tar.gz" % (bazel_toolchains_version, bazel_toolchains_version),
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

# Creates toolchain configuration for remote execution with BuildKite CI
# for rbe_ubuntu1604
rbe_autoconfig(
    name = "buildkite_config",
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
        "org_spire_math_kind_projector",
        # For testing that we don't include sources jars to the classpath
        "org_typelevel__cats_core",
    ],
    maven_servers = MAVEN_SERVER_URLS,
)
