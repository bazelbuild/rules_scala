load("//scala:scala.bzl", "scala_binary")
load("//third_party/repositories:repositories.bzl", "repositories")

def tut_repositories(
        overriden_artifacts = {},
        server_urls = ["https://dl.bintray.com/tpolecat/maven/"]):
    repositories(
        for_artifact_ids = [
            "io_bazel_rules_scala_org_tpolecat_tut_core",
        ],
        maven_servers = server_urls,
        fetch_sources = False,
        overriden_artifacts = overriden_artifacts,
    )

    native.register_toolchains("@io_bazel_rules_scala//tut_rule:tut_toolchain")

def scala_tut_doc(**kw):
    name = kw["name"]
    deps = kw.get("deps", [])
    src = kw["src"]
    tool = "%s_compiler" % name
    scala_binary(
        name = tool,
        main_class = "io.bazel.rules_scala.tut_support.TutCompiler",
        deps = deps + [
            "@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/tut_support:tut_compiler_lib",
            "@io_bazel_rules_scala//scala/private/toolchain_deps:scala_library_classpath",
        ],
    )
    native.genrule(
        name = name,
        srcs = [src],
        outs = ["%s_tut.md" % name],
        tools = [tool],
        cmd = "./$(location %s) $(location %s) \"$@\" >/dev/null" % (tool, src),
    )
