workspace(name = "io_bazel_rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:jvm.bzl", "jvm_maven_import_external")

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "cdaac537b56375f658179ee2f27813cac19542443f4722b6730d84e4125355e6",
    strip_prefix = "buildtools-f27d1753c8b3210d9e87cdc9c45bc2739ae2c2db",
    url = "https://github.com/bazelbuild/buildtools/archive/f27d1753c8b3210d9e87cdc9c45bc2739ae2c2db.zip",
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

load("//scala:scala.bzl", "scala_repositories")

scala_repositories()

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

load("//scala/scalafmt:scalafmt.bzl", "scalafmt_default_config", "scalafmt_repositories")

scalafmt_repositories()

scalafmt_default_config()

RULES_JVM_EXTERNAL_TAG = "3.1"

http_archive(
    name = "rules_jvm_external",
    sha256 = "e246373de2353f3d34d35814947aa8b7d0dd1a58c2f7a6c41cfeaff3007c2d14",
    strip_prefix = "rules_jvm_external-{}".format(RULES_JVM_EXTERNAL_TAG),
    type = "zip",
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/{}.zip".format(RULES_JVM_EXTERNAL_TAG),
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    name = "scalafmt",
    artifacts = [
        "org.scalameta:scalafmt-core_2.11:2.0.0",
    ],
    fetch_sources = True,
    repositories = [
        "http://central.maven.org/maven2",
    ],
)

load("//scala:scala_cross_version.bzl", "default_scala_major_version", "scala_mvn_artifact")

MAVEN_SERVER_URLS = [
    "https://jcenter.bintray.com",
    "https://repo1.maven.org/maven2",
]

# test adding a scala jar:
jvm_maven_import_external(
    name = "com_twitter__scalding_date",
    artifact = scala_mvn_artifact(
        "com.twitter:scalding-date:0.17.0",
        default_scala_major_version(),
    ),
    artifact_sha256 = "bf743cd6d224a4568d6486a2b794143e23145d2afd7a1d2de412d49e45bdb308",
    server_urls = MAVEN_SERVER_URLS,
)

# For testing that we don't include sources jars to the classpath
jvm_maven_import_external(
    name = "org_typelevel__cats_core",
    artifact = scala_mvn_artifact(
        "org.typelevel:cats-core:0.9.0",
        default_scala_major_version(),
    ),
    artifact_sha256 = "3fda7a27114b0d178107ace5c2cf04e91e9951810690421768e65038999ffca5",
    server_urls = MAVEN_SERVER_URLS,
)

# test of a plugin
jvm_maven_import_external(
    name = "org_psywerx_hairyfotr__linter",
    artifact = scala_mvn_artifact(
        "org.psywerx.hairyfotr:linter:0.1.13",
        default_scala_major_version(),
    ),
    artifact_sha256 = "9444dd78684c0cc89d070af0f5ca3f3ae7d56b2a4d7ac1c038f8218ad4d66fad",
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
    server_urls = [
        "https://repo.maven.apache.org/maven2/",
    ],
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
    server_urls = [
        "https://repo1.maven.org/maven2/",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
    ],
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

http_archive(
    name = "bazel_toolchains",
    sha256 = "8062febd539d2f3246e479715e3f1eb29f0420eca26da369950309cb2bed25fd",
    strip_prefix = "bazel-toolchains-0b442a1bf997840c4f1063ee8a90605392418741",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/0b442a1bf997840c4f1063ee8a90605392418741.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/0b442a1bf997840c4f1063ee8a90605392418741.tar.gz",
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
    server_urls = [
        "https://repo1.maven.org/maven2/",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
    ],
)

scala_maven_import_external(
    name = "org_springframework_spring_tx",
    artifact = "org.springframework:spring-tx:5.1.5.RELEASE",
    artifact_sha256 = "666f72b73c7e6b34e5bb92a0d77a14cdeef491c00fcb07a1e89eb62b08500135",
    licenses = ["notice"],  # Apache 2.0
    server_urls = [
        "https://repo1.maven.org/maven2/",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
    ],
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
    artifact_sha256 = "897460d4488b7dd6ac9198937d6417b36cc6ec8ab3693fdf2c532652f26c4373",
    fetch_sources = False,
    licenses = ["notice"],
    server_urls = [
        "https://repo.maven.apache.org/maven2/",
    ],
)
