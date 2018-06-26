load("//specs2:specs2.bzl", "specs2_repositories", "specs2_dependencies",
     "specs2_version")
load("//scala:scala_cross_version.bzl", "scala_mvn_artifact")
load("//junit:junit.bzl", "junit_repositories")

def specs2_junit_repositories(scala_version = "2.11.11"):
  major_version = scala_version[:scala_version.find(".", 2)]

  specs2_repositories(scala_version)
  junit_repositories()
  # Aditional dependencies for specs2 junit runner
  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_junit",
      artifact = "org.specs2:specs2-junit_{}:".format(major_version) + specs2_version(),
      #sha1 = "1dc9e43970557c308ee313842d84094bc6c1c1b5",
  )

  native.bind(
      name = 'io_bazel_rules_scala/dependency/specs2/specs2_junit',
      actual = '@io_bazel_rules_scala_org_specs2_specs2_junit//jar')

def specs2_junit_dependencies():
  return specs2_dependencies() + [
      "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit"
  ]
