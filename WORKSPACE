workspace(name = "io_bazel_rules_scala")

BAZEL_VERSION = "0.6.0rc1"
BAZEL_VERSION_SHA = "43571405d296be05ef9cc875cb90c49be17409d7cd4d5a81c7bb84b33cbf7707"
BAZEL_ZIP_PATH = "https://storage.googleapis.com/bazel/0.6.0/rc1/bazel-0.6.0rc1-dist.zip"


load("//scala:scala.bzl", "scala_repositories", "scala_mvn_artifact")
scala_repositories()

load("//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge", "scrooge_scala_library")
twitter_scrooge()

load("//tut_rule:tut.bzl", "tut_repositories")
tut_repositories()

load("//jmh:jmh.bzl", "jmh_repositories")
jmh_repositories()

load("//specs2:specs2_junit.bzl","specs2_junit_repositories")
specs2_junit_repositories()

# test adding a scala jar:
maven_jar(
  name = "com_twitter__scalding_date",
  artifact = scala_mvn_artifact("com.twitter:scalding-date:0.16.0-RC4"),
  sha1 = "659eb2d42945dea37b310d96af4e12bf83f54d14"
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