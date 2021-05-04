load("//scala:scala.bzl", "scala_binary")
load("//third_party/repositories:repositories.bzl", "repositories")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def tut_source_repositories():
    http_archive(
        name = "io_bazel_rules_scala_org_tpolecat_tut_core",
        url = "https://github.com/tpolecat/tut/archive/refs/tags/v0.6.13.tar.gz",
        build_file_content = """
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")
scala_library(
    name = "io_bazel_rules_scala_org_tpolecat_tut_core",
    srcs = glob([
        "scala/**/*.scala",
         "scala-2.13+/**/*.scala" if SCALA_MAJOR_VERSION == "2.13" else "scala-2.12-/**/*.scala"
    ]),
    deps = ["@io_bazel_rules_scala//scala/private/toolchain_deps:scala_compile_classpath"],
    visibility = ["//visibility:public"],
)
""",
        sha256 = "a307eae349e3a3d51ff6a8d1ddc753f85c5c0423edfcc189a75dad53348f68af",
        strip_prefix = "tut-0.6.13/modules/core/src/main",
    )

    native.register_toolchains("@io_bazel_rules_scala//tut_rule:tut_toolchain")

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
            "@io_bazel_rules_scala//tut_rule/compiler/io/bazel/rules_scala/tut_support:tut_compiler_lib",
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
