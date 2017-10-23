load("//scala:scala_cross_version.bzl",
  "scala_mvn_artifact",
  )

def specs2_version():
  return "3.8.8"
def specs2_repositories():

  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_core",
      artifact = scala_mvn_artifact("org.specs2:specs2-core:" + specs2_version()),
      sha1 = "495bed00c73483f4f5f43945fde63c615d03e637",
  )

  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_common",
      artifact = scala_mvn_artifact("org.specs2:specs2-common:" + specs2_version()),
      sha1 = "15bc009eaae3a574796c0f558d8696b57ae903c3",
  )

  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_matcher",
      artifact = scala_mvn_artifact("org.specs2:specs2-matcher:" + specs2_version()),
      sha1 = "d2e967737abef7421e47b8994a8c92784e624d62",
  )

  native.maven_jar(
      name = "io_bazel_rules_scala_org_scalaz_scalaz_effect",
      artifact = scala_mvn_artifact("org.scalaz:scalaz-effect:7.2.7"),
      sha1 = "824bbb83da12224b3537c354c51eb3da72c435b5",
  )

  native.maven_jar(
      name = "io_bazel_rules_scala_org_scalaz_scalaz_core",
      artifact = scala_mvn_artifact("org.scalaz:scalaz-core:7.2.7"),
      sha1 = "ebf85118d0bf4ce18acebf1d8475ee7deb7f19f1",
  )

  native.bind(name = 'io_bazel_rules_scala/dependency/specs2/specs2', actual = "@io_bazel_rules_scala//specs2:specs2")

def specs2_dependencies():
  return ["//external:io_bazel_rules_scala/dependency/specs2/specs2"]
