workspace(name = "io_bazel_rules_scala")

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

# test of a plugin
maven_jar(
  name = "org_psywerx_hairyfotr__linter",
  artifact = scala_mvn_artifact("org.psywerx.hairyfotr:linter:0.1.13"),
  sha1 = "e5b3e2753d0817b622c32aedcb888bcf39e275b4")


# dependencies needed for BazelTestRunner
maven_server(
    name = "one_hippo",
    url = "http://maven.onehippo.com/maven2/",
)

maven_jar(
      name = "javax_inject",
      artifact = "javax.inject:javax.inject:1")

maven_jar(
      name = "javax_annotation_inject",
      artifact = "javax.annotation:jsr305:1.0",
      server = "one_hippo")