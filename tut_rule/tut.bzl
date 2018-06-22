load("//scala:scala.bzl", "scala_binary")
load("//scala:scala_cross_version.bzl", "scala_mvn_artifact")

def tut_repositories(scala_version = "2.11.11"):
  major_version_underscore = scala_version[:scala_version.find(".", 2)].replace(
      ".", "_")
  native.maven_server(
      name = "tut_repositories_maven_server",
      url = "https://dl.bintray.com/tpolecat/maven/",
  )

  native.maven_jar(
      name = "io_bazel_rules_scala_org_tpolecat_tut_core_2_11",
      artifact = scala_mvn_artifact("org.tpolecat:tut-core:0.4.8"),
      sha1 = "fc723eb822494580cc05d6b3b3a6039d2280a5a0",
      server = "tut_repositories_maven_server",
  )
  native.maven_jar(
      name = "io_bazel_rules_scala_org_tpolecat_tut_core_2_12",
      artifact = "org.tpolecat:tut-core_2.12:0.4.8",
      server = "tut_repositories_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/tut/tut_core',
      actual = '@io_bazel_rules_scala_org_tpolecat_tut_core_{}//jar'.format(
          major_version_underscore))

def scala_tut_doc(**kw):
  name = kw["name"]
  deps = kw.get("deps", [])
  src = kw["src"]
  tool = "%s_compiler" % name
  scala_binary(
      name = tool,
      main_class = "io.bazel.rules_scala.tut_support.TutCompiler",
      deps = deps + [
          "@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/tut_support:tut_compiler_lib"
      ],
  )
  native.genrule(
      name = name,
      srcs = [src],
      outs = ["%s_tut.md" % name],
      tools = [tool],
      cmd = "./$(location %s) $(location %s) \"$@\"" % (tool, src))
