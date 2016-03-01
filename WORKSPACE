workspace(name = "io_bazel_rules_scala")

load("//scala:scala.bzl", "scala_repositories", "scala_mvn_artifact")
scala_repositories()

# test adding a scala jar:
maven_jar(
  name = "com_twitter__scalding_date",
  artifact = scala_mvn_artifact("com.twitter:scalding-date:0.16.0-RC4")
)
