workspace(name = "io_bazel_rules_scala")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//scala:scala.bzl", "scala_repositories")

scala_repositories()

load("//scala:scala_maven_import_external.bzl", "scala_maven_import_external")
load("//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge", "scrooge_scala_library")

twitter_scrooge()

load("//tut_rule:tut.bzl", "tut_repositories")

tut_repositories()

load("//jmh:jmh.bzl", "jmh_repositories")

jmh_repositories()

load("//scala_proto:scala_proto.bzl", "scala_proto_repositories")

scala_proto_repositories()

load("//specs2:specs2_junit.bzl", "specs2_junit_repositories")

specs2_junit_repositories()

load("//scala:scala_cross_version.bzl", "scala_mvn_artifact", "default_scala_major_version")

# test adding a scala jar:
maven_jar(
    name = "com_twitter__scalding_date",
    artifact = scala_mvn_artifact(
        "com.twitter:scalding-date:0.17.0",
        default_scala_major_version(),
    ),
    sha1 = "420fb0c4f737a24b851c4316ee0362095710caa5",
)

# For testing that we don't include sources jars to the classpath
maven_jar(
    name = "org_typelevel__cats_core",
    artifact = scala_mvn_artifact(
        "org.typelevel:cats-core:0.9.0",
        default_scala_major_version(),
    ),
    sha1 = "b2f8629c6ec834d8b6321288c9fe77823f1e1314",
)

# test of a plugin
maven_jar(
    name = "org_psywerx_hairyfotr__linter",
    artifact = scala_mvn_artifact(
        "org.psywerx.hairyfotr:linter:0.1.13",
        default_scala_major_version(),
    ),
    sha1 = "e5b3e2753d0817b622c32aedcb888bcf39e275b4",
)

# test of strict deps (scalac plugin UT + E2E)
maven_jar(
    name = "com_google_guava_guava_21_0_with_file",
    artifact = "com.google.guava:guava:21.0",
    sha1 = "3a3d111be1be1b745edfa7d91678a12d7ed38709",
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
    fetch_sources = True,
    jar_sha256 = "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
    licenses = ["notice"],
    server_urls = [
        "https://repo.maven.apache.org/maven2/",
    ],
    srcjar_sha256 = "5e586357a289f5fe896f7b48759e1c16d9fa419333156b496696887e613d7a19",
)

maven_jar(
    name = "org_apache_commons_commons_lang_3_5",
    artifact = "org.apache.commons:commons-lang3:3.5",
    sha1 = "6c6c702c89bfff3cd9e80b04d668c5e190d588c6",
)

http_archive(
    name = "com_google_protobuf",
    sha256 = "9510dd2afc29e7245e9e884336f848c8a6600a14ae726adb6befdb4f786f0be2",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.6.1.3.zip"],
    strip_prefix = "protobuf-3.6.1.3",
)

http_archive(
    name = "com_google_protobuf_java",
    sha256 = "9510dd2afc29e7245e9e884336f848c8a6600a14ae726adb6befdb4f786f0be2",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.6.1.3.zip"],
    strip_prefix = "protobuf-3.6.1.3",
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

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_unused_deps_toolchains")

scala_register_unused_deps_toolchains()

load("//scala:scala_maven_import_external.bzl", "scala_maven_import_external", "java_import_external")

scala_maven_import_external(
    name = "com_google_guava_guava_21_0",
    artifact = "com.google.guava:guava:21.0",
    jar_sha256 = "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    srcjar_sha256 = "b186965c9af0a714632fe49b33378c9670f8f074797ab466f49a67e918e116ea",
    fetch_sources = True,
    licenses = ["notice"],  # Apache 2.0
    server_urls = [
        "https://repo1.maven.org/maven2/",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
        ],
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
    jar_urls = ["http://central.maven.org/maven2/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar"],
    licenses = ["notice"],  # Apache 2.0
    neverlink = True,
)

## Linting

load("//private:format.bzl", "format_repositories")

format_repositories()

http_archive(
    name = "bazel_toolchains",
    sha256 = "7e85a14821536bc24e04610d309002056f278113c6cc82f1059a609361812431",
    strip_prefix = "bazel-toolchains-bc0091adceaf4642192a8dcfc46e3ae3e4560ea7",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/bc0091adceaf4642192a8dcfc46e3ae3e4560ea7.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/bc0091adceaf4642192a8dcfc46e3ae3e4560ea7.tar.gz",
    ],
)

git_repository(
    name = "bazel_skylib",
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    tag = "0.6.0",
)