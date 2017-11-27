workspace(name = "io_bazel_rules_scala")



load("//scala:scala.bzl", "scala_repositories", "scala_mvn_artifact")
scala_repositories()

load("//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge", "scrooge_scala_library")
twitter_scrooge()

load("//tut_rule:tut.bzl", "tut_repositories")
tut_repositories()

load("//jmh:jmh.bzl", "jmh_repositories")
jmh_repositories()

load("//scala_proto:scala_proto.bzl", "scala_proto_repositories")
scala_proto_repositories()

load("//specs2:specs2_junit.bzl","specs2_junit_repositories")
specs2_junit_repositories()

# test adding a scala jar:
maven_jar(
  name = "com_twitter__scalding_date",
  artifact = scala_mvn_artifact("com.twitter:scalding-date:0.17.0"),
  sha1 = "420fb0c4f737a24b851c4316ee0362095710caa5"
)

# For testing that we don't include sources jars to the classpath
maven_jar(
  name = "org_typelevel__cats_core",
  artifact = scala_mvn_artifact("org.typelevel:cats-core:0.9.0"),
  sha1 = "b2f8629c6ec834d8b6321288c9fe77823f1e1314"
)


# test of a plugin
maven_jar(
  name = "org_psywerx_hairyfotr__linter",
  artifact = scala_mvn_artifact("org.psywerx.hairyfotr:linter:0.1.13"),
  sha1 = "e5b3e2753d0817b622c32aedcb888bcf39e275b4")

# test of strict deps (scalac plugin UT + E2E)
maven_jar(
    name = "com_google_guava_guava_21_0",
    artifact = "com.google.guava:guava:21.0",
    sha1 = "3a3d111be1be1b745edfa7d91678a12d7ed38709"
)

maven_jar(
    name = "org_apache_commons_commons_lang_3_5",
    artifact = "org.apache.commons:commons-lang3:3.5",
    sha1 = "6c6c702c89bfff3cd9e80b04d668c5e190d588c6"
)

http_archive(
    name = "com_google_protobuf",
    urls = ["https://github.com/google/protobuf/archive/b04e5cba356212e4e8c66c61bbe0c3a20537c5b9.zip"],
    strip_prefix = "protobuf-b04e5cba356212e4e8c66c61bbe0c3a20537c5b9",
    sha256 = "cf4a434ac3a83040e9f65be92e153d00d075d8cd25e3f6c6d8670879f5796aa0",
)

http_archive(
    name = "com_google_protobuf_java",
    urls = ["https://github.com/google/protobuf/archive/b04e5cba356212e4e8c66c61bbe0c3a20537c5b9.zip"],
    strip_prefix = "protobuf-b04e5cba356212e4e8c66c61bbe0c3a20537c5b9",
    sha256 = "cf4a434ac3a83040e9f65be92e153d00d075d8cd25e3f6c6d8670879f5796aa0",
)

new_local_repository(
    name = "test_new_local_repo",
    path = "third_party/test/new_local_repo",
    build_file_content = 
"""
filegroup(
    name = "data",
    srcs = glob(["**/*.txt"]),
    visibility = ["//visibility:public"],
)
"""
)
