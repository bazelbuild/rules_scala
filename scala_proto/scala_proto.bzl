load(
    "//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
)
load(
    "//scala_proto/private:scala_proto_default_repositories.bzl",
    "scala_proto_default_repositories",
)
load(
    "//scala_proto/private:scalapb_aspect.bzl",
    "ScalaPBAspectInfo",
    "ScalaPBInfo",
    "merge_scalapb_aspect_info",
    "scalapb_aspect",
)

def scala_proto_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    return scala_proto_default_repositories(scala_version, maven_servers)

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
        "deps": attr.label_list(aspects = [scalapb_aspect]),
    },
    provides = [DefaultInfo, ScalaPBInfo, JavaInfo],
)
