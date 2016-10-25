workspace(name = "io_bazel_rules_scala")

load("//scala:scala.bzl", "scala_repositories", "scala_mvn_artifact")
scala_repositories()

load("//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge", "scrooge_scala_library")
twitter_scrooge()

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


git_repository(
    name = "io_bazel",
      remote = "git://github.com/bazelbuild/bazel.git",
      tag = "0.3.1",
)
