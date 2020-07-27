workspace(name = "io_bazel_rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:jvm.bzl", "jvm_maven_import_external")

_build_tools_release = "3.3.0"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "f11fc80da0681a6d64632a850346ed2d4e5cbb0908306d9a2a2915f707048a10",
    strip_prefix = "buildtools-%s" % _build_tools_release,
    url = "https://github.com/bazelbuild/buildtools/archive/%s.tar.gz" % _build_tools_release,
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

load("//scala:scala.bzl", "scala_repositories")

scala_repositories(fetch_sources = True)

load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:scala_maven_import_external.bzl", "scala_maven_import_external")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library", "twitter_scrooge")

twitter_scrooge()

load("//tut_rule:tut.bzl", "tut_repositories")

tut_repositories()

load("//jmh:jmh.bzl", "jmh_repositories")

jmh_repositories()

load("//scala_proto:scala_proto.bzl", "scala_proto_repositories")

scala_proto_repositories()

load("//specs2:specs2_junit.bzl", "specs2_junit_repositories")

specs2_junit_repositories()

load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_default_config", "scalafmt_repositories")

scalafmt_default_config()

scalafmt_repositories()

load("//scala:scala_cross_version.bzl", "default_scala_major_version", "scala_mvn_artifact")

MAVEN_SERVER_URLS = default_maven_server_urls()

# needed for the cross repo proto test
load("//test/proto_cross_repo_boundary:repo.bzl", "proto_cross_repo_boundary_repository")

proto_cross_repo_boundary_repository()

# test adding a scala jar:
jvm_maven_import_external(
    name = "com_twitter__scalding_date",
    artifact = scala_mvn_artifact(
        "com.twitter:scalding-date:0.17.0",
        default_scala_major_version(),
    ),
    artifact_sha256 = "973a7198121cc8dac9eeb3f325c93c497fe3b682f68ba56e34c1b210af7b15b3",
    server_urls = MAVEN_SERVER_URLS,
)

# For testing that we don't include sources jars to the classpath
jvm_maven_import_external(
    name = "org_typelevel__cats_core",
    artifact = scala_mvn_artifact(
        "org.typelevel:cats-core:0.9.0",
        default_scala_major_version(),
    ),
    artifact_sha256 = "3ca705cba9dc0632e60477d80779006f8c636c0e2e229dda3410a0c314c1ea1d",
    server_urls = MAVEN_SERVER_URLS,
)

# test of a plugin
jvm_maven_import_external(
    name = "org_psywerx_hairyfotr__linter",
    artifact = scala_mvn_artifact(
        "org.psywerx.hairyfotr:linter:0.1.17",
        default_scala_major_version(),
    ),
    artifact_sha256 = "59becd7883613064842b3a62f84315b02457dc439f42ef62e3c80408393c905b",
    server_urls = MAVEN_SERVER_URLS,
)

# test of strict deps (scalac plugin UT + E2E)
jvm_maven_import_external(
    name = "com_google_guava_guava_21_0_with_file",
    artifact = "com.google.guava:guava:21.0",
    artifact_sha256 = "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    server_urls = MAVEN_SERVER_URLS,
)

# test of import external
# scala maven import external decodes maven artifacts to its parts
# (group id, artifact id, packaging, version and classifier). To make sure
# the decoding and then the download url composition are working the artifact example
# must contain all the different parts and sha256s so the downloaded content will be
# validated against it
scala_maven_import_external(
    name = "com_github_jnr_jffi_native",
    artifact = "com.github.jnr:jffi:jar:native:1.2.17",
    artifact_sha256 = "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
    fetch_sources = True,
    licenses = ["notice"],
    server_urls = MAVEN_SERVER_URLS,
    srcjar_sha256 = "5e586357a289f5fe896f7b48759e1c16d9fa419333156b496696887e613d7a19",
)

jvm_maven_import_external(
    name = "org_apache_commons_commons_lang_3_5",
    artifact = "org.apache.commons:commons-lang3:3.5",
    artifact_sha256 = "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    server_urls = MAVEN_SERVER_URLS,
)

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

load("//scala:scala_maven_import_external.bzl", "java_import_external", "scala_maven_import_external")

scala_maven_import_external(
    name = "com_google_guava_guava_21_0",
    artifact = "com.google.guava:guava:21.0",
    artifact_sha256 = "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    fetch_sources = True,
    licenses = ["notice"],  # Apache 2.0
    server_urls = MAVEN_SERVER_URLS,
    srcjar_sha256 = "b186965c9af0a714632fe49b33378c9670f8f074797ab466f49a67e918e116ea",
)

# bazel's java_import_external has been altered in rules_scala to be a macro based on jvm_import_external
# in order to allow for other jvm-language imports (e.g. scala_import)
# the 3rd-party dependency below is using the java_import_external macro
# in order to make sure no regression with the original java_import_external
load("//scala:scala_maven_import_external.bzl", "java_import_external")

java_import_external(
    name = "org_apache_commons_commons_lang_3_5_without_file",
    generated_linkable_rule_name = "linkable_org_apache_commons_commons_lang_3_5_without_file",
    jar_sha256 = "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    jar_urls = ["https://repo.maven.apache.org/maven2/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar"],
    licenses = ["notice"],  # Apache 2.0
    neverlink = True,
)

## Linting

load("//private:format.bzl", "format_repositories")

format_repositories()

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "45409e6c4f748baa9e05f8f6ab6efaa05739aa064e3ab94e5a1a09849c51806a",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.18.7/rules_go-0.18.7.tar.gz",
)

load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)

go_rules_dependencies()

go_register_toolchains()

bazel_toolchains_version = "3.4.0"

bazel_toolchains_sha256 = "882fecfc88d3dc528f5c5681d95d730e213e39099abff2e637688a91a9619395"

http_archive(
    name = "bazel_toolchains",
    sha256 = bazel_toolchains_sha256,
    strip_prefix = "bazel-toolchains-%s" % bazel_toolchains_version,
    urls = [
        "https://github.com/bazelbuild/bazel-toolchains/releases/download/%s/bazel-toolchains-%s.tar.gz" % (bazel_toolchains_version, bazel_toolchains_version),
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/%s.tar.gz" % bazel_toolchains_version,
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

## deps for tests of limited deps support

scala_maven_import_external(
    name = "org_springframework_spring_core",
    artifact = "org.springframework:spring-core:5.1.5.RELEASE",
    artifact_sha256 = "f771b605019eb9d2cf8f60c25c050233e39487ff54d74c93d687ea8de8b7285a",
    licenses = ["notice"],  # Apache 2.0
    server_urls = MAVEN_SERVER_URLS,
)

scala_maven_import_external(
    name = "org_springframework_spring_tx",
    artifact = "org.springframework:spring-tx:5.1.5.RELEASE",
    artifact_sha256 = "666f72b73c7e6b34e5bb92a0d77a14cdeef491c00fcb07a1e89eb62b08500135",
    licenses = ["notice"],  # Apache 2.0
    server_urls = MAVEN_SERVER_URLS,
    deps = [
        "@org_springframework_spring_core",
    ],
)

## deps for tests of compiler plugin
scala_maven_import_external(
    name = "org_spire_math_kind_projector",
    artifact = scala_mvn_artifact(
        "org.spire-math:kind-projector:0.9.10",
        default_scala_major_version(),
    ),
    artifact_sha256 = "36aca2493302e2c037328107a121cda1d28bf9119fbc04fb47ea1ff9bce3c03f",
    fetch_sources = False,
    licenses = ["notice"],
    server_urls = MAVEN_SERVER_URLS,
)
