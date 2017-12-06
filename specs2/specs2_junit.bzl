load("//specs2:specs2.bzl", "specs2_repositories", "specs2_dependencies", "specs2_version")
load("//scala:scala_cross_version.bzl", "scala_mvn_artifact")
load("//junit:junit.bzl", "junit_repositories")
  
def specs2_junit_repositories():
  specs2_repositories()  
  junit_repositories()
  # Aditional dependencies for specs2 junit runner
  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_junit_2_11",
      artifact = scala_mvn_artifact("org.specs2:specs2-junit:" + specs2_version()),
      sha1 = "1dc9e43970557c308ee313842d84094bc6c1c1b5",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/specs2/specs2_junit', actual = '@io_bazel_rules_scala_org_specs2_specs2_junit_2_11//jar')

def specs2_junit_dependencies():
    return specs2_dependencies() + ["//external:io_bazel_rules_scala/dependency/specs2/specs2_junit"]
