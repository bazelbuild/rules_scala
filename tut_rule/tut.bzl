load("//scala:scala.bzl", "scala_binary")
load(
    "//scala:scala_cross_version.bzl",
    "scala_mvn_artifact",
    _default_scala_version = "default_scala_version",
    _extract_major_version = "extract_major_version",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def tut_repositories(
        scala_version = _default_scala_version(),
        server_urls = ["https://dl.bintray.com/tpolecat/maven/"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "tut_core": "edab4e9963dd7dbab1a8bfff2ef087eb6b6882804dfb3a2641895c958a62ba89",
        },
        "2.12": {
            "tut_core": "767735128b6d5694d59ccb3bd1f5544a05d83146577121bcf7b6a32327adf281",
        },
    }

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_tpolecat_tut_core",
        artifact = scala_mvn_artifact(
            "org.tpolecat:tut-core:0.4.8",
            major_version,
        ),
        jar_sha256 = scala_jar_shas[major_version]["tut_core"],
        licenses = ["notice"],
        server_urls = server_urls,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/tut/tut_core",
        actual = "@io_bazel_rules_scala_org_tpolecat_tut_core",
    )

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
            "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        ],
    )
    native.genrule(
        name = name,
        srcs = [src],
        outs = ["%s_tut.md" % name],
        tools = [tool],
        cmd = "./$(location %s) $(location %s) \"$@\" >/dev/null" % (tool, src),
    )
