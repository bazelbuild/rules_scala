load("//scala:scala_cross_version.bzl",
  "scala_mvn_artifact",
  )

def specs2_version():
  return "3.8.8"
def specs2_repositories():

  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_core",
      artifact = scala_mvn_artifact("org.specs2:specs2-core:" + specs2_version()),
      sha1 = "86cb72427e64e1423edcbf082e8767a60493bbcc",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/specs2/specs2_core', actual = '@io_bazel_rules_scala_org_specs2_specs2_core//jar')
  
  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_common",
      artifact = scala_mvn_artifact("org.specs2:specs2-common:" + specs2_version()),
      sha1 = "83bd14fb54f81a886901fa7ed136bcf887322440",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/specs2/specs2_common', actual = '@io_bazel_rules_scala_org_specs2_specs2_common//jar')
  
  native.maven_jar(
      name = "io_bazel_rules_scala_org_specs2_specs2_matcher",
      artifact = scala_mvn_artifact("org.specs2:specs2-matcher:" + specs2_version()),
      sha1 = "921d9ef6bf98c3e5a59d535e1139b5522625d6ba",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/specs2/specs2_matcher', actual = '@io_bazel_rules_scala_org_specs2_specs2_matcher//jar')
  
  native.maven_jar(
      name = "io_bazel_rules_scala_org_scalaz_scalaz_effect",
      artifact = scala_mvn_artifact("org.scalaz:scalaz-effect:7.2.7"),
      sha1 = "5d0bbd74323d8c7467cde95dcdc298eb3d9dcdb1",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/scalaz/scalaz_effect', actual = '@io_bazel_rules_scala_org_scalaz_scalaz_effect//jar')

  native.maven_jar(
      name = "io_bazel_rules_scala_org_scalaz_scalaz_core",
      artifact = scala_mvn_artifact("org.scalaz:scalaz-core:7.2.7"),
      sha1 = "ee06c07e856bad6ce112b2a5b96e1df1609ad57f",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/scalaz/scalaz_core', actual = '@io_bazel_rules_scala_org_scalaz_scalaz_core//jar')

def specs2_dependencies():
  return [
  "//external:io_bazel_rules_scala/dependency/specs2/specs2_core",
  "//external:io_bazel_rules_scala/dependency/specs2/specs2_common",
  "//external:io_bazel_rules_scala/dependency/specs2/specs2_matcher",
  "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_effect",
  "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_core",
  "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
  "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
  "//external:io_bazel_rules_scala/dependency/scala/scala_library",
  "//external:io_bazel_rules_scala/dependency/scala/scala_reflect"]  
