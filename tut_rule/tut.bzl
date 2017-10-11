load("//scala:scala.bzl", "scala_binary")

def tut_repositories():
  native.maven_server(
    name = "tut_repositories_maven_server",
    url = "https://dl.bintray.com/tpolecat/maven/",
  )

  native.maven_jar(
    name = "io_bazel_rules_scala_org_tpolecat_tut_core",
    artifact = "org.tpolecat:tut-core_2.12:0.4.8",
    sha1 = "b68b5a52474bf249d1156f5002033498054b813c",
    server = "tut_repositories_maven_server",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/tut/tut_core', actual = '@io_bazel_rules_scala_org_tpolecat_tut_core//jar')

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
      cmd = "./$(location %s) $(location %s) \"$@\"" % (tool, src)
      )
