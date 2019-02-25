load(
    "//scala:scala.bzl",
    "scala_library",
)
load(
    "//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
    _extract_major_version = "extract_major_version",
    _scala_mvn_artifact = "scala_mvn_artifact",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load(
    "//scala/private:common.bzl",
    "collect_jars",
    "create_java_provider",
)

load(
    "//scala_proto/private:scala_proto_default_repositories.bzl",
    "scala_proto_default_repositories",
)

load(
    "//scala_proto/private:scalapb_aspect.bzl",
    "scalapb_aspect",
    "ScalaPBInfo",
    "merge_scalapb_aspect_info",
    "ScalaPBAspectInfo",
)



def scala_proto_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    return scala_proto_default_repositories(scala_version, maven_servers)


"""Generate scalapb bindings for a set of proto_library targets.

Example:
    scalapb_proto_library(
        name = "exampla_proto_scala",
        deps = ["//src/proto:example_service"]
    )

Args:
    name: A unique name for this rule
    deps: Proto library or java proto library (if with_java is True) targets that this rule depends on

Outputs:
    A scala_library rule that includes the generated scalapb bindings, as
    well as any library dependencies needed to compile and use these.
"""


def _scalapb_proto_library_impl(ctx):
    aspect_info = merge_scalapb_aspect_info(
        [dep[ScalaPBAspectInfo] for dep in ctx.attr.deps],
    )
    all_java = aspect_info.java_info

    return [
        all_java,
        ScalaPBInfo(aspect_info = aspect_info),
        DefaultInfo(files = aspect_info.output_files),
    ]

scalapb_proto_library = rule(
    implementation = _scalapb_proto_library_impl,
    attrs = {
        "deps": attr.label_list(aspects = [scalapb_aspect])
    },
    provides = [DefaultInfo, ScalaPBInfo, JavaInfo],
)
