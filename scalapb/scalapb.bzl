load(
    "//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
)
load(
    "//scalapb/private:scalapb_default_repositories.bzl",
    "scalapb_default_repositories",
)
load(
    "//scalapb/private:scalapb_aspect.bzl",
    "ScalaPBAspectInfo",
    "ScalaPBInfo",
    "merge_scalapb_aspect_info",
    "scalapb_aspect",
)

def register_default_proto_dependencies():
    if native.existing_rule("io_bazel_rules_scala/dependency/proto/grpc_deps") == None:
        native.bind(
            name = "io_bazel_rules_scala/dependency/proto/grpc_deps",
            actual = "@io_bazel_rules_scala//scalapb:default_scalapb_grpc_dependencies",
        )

    if native.existing_rule("io_bazel_rules_scala/dependency/proto/implicit_compile_deps") == None:
        native.bind(
            name = "io_bazel_rules_scala/dependency/proto/implicit_compile_deps",
            actual = "@io_bazel_rules_scala//scalapb:default_scalapb_compile_dependencies",
        )



def scalapb_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    ret =  scalapb_default_repositories(scala_version, maven_servers)
    register_default_proto_dependencies()
    return ret



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
