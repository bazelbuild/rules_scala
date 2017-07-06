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

# test of a scala plugin
maven_jar(
  name = "io_get_coursier_coursier_cache",
  artifact = "io.get-coursier:coursier-cache_2.11:jar:1.0.0-M15",
  sha1 = "cbf7a208ccd4c3ad44efa3886e237ecbf96a6fd9")

maven_jar(
  name = "io_get_coursier_coursier",
  artifact = "io.get-coursier:coursier_2.11:jar:1.0.0-M15",
  sha1 = "9c6281274f9964a786cba4a5df62740c07b07046")

maven_jar(
    name = "org_scalaz_scalaz_concurrent_2_11",
    artifact = "org.scalaz:scalaz-concurrent_2.11:jar:7.2.7",
    sha1 = "abaea3aa04f11301f63099d96cf47f91ec229ed4"
)