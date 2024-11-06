load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//third_party/repositories:repositories.bzl", "repositories")

def scala_proto_default_repositories(
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {}):
    repositories(
        for_artifact_ids = [
            "com_google_protobuf_protobuf_java",
            "com_lihaoyi_fastparse",
            "com_lihaoyi_sourcecode",
            "io_bazel_rules_scala_guava",
            "scala_proto_rules_disruptor",
            "scala_proto_rules_instrumentation_api",
            "scala_proto_rules_grpc_api",
            "scala_proto_rules_grpc_context",
            "scala_proto_rules_grpc_core",
            "scala_proto_rules_grpc_netty",
            "scala_proto_rules_grpc_protobuf",
            "scala_proto_rules_grpc_stub",
            "scala_proto_rules_netty_buffer",
            "scala_proto_rules_netty_codec",
            "scala_proto_rules_netty_codec_http",
            "scala_proto_rules_netty_codec_http2",
            "scala_proto_rules_netty_codec_socks",
            "scala_proto_rules_netty_common",
            "scala_proto_rules_netty_handler",
            "scala_proto_rules_netty_handler_proxy",
            "scala_proto_rules_netty_resolver",
            "scala_proto_rules_netty_transport",
            "scala_proto_rules_opencensus_api",
            "scala_proto_rules_opencensus_contrib_grpc_metrics",
            "scala_proto_rules_opencensus_impl",
            "scala_proto_rules_opencensus_impl_core",
            "scala_proto_rules_perfmark_api",
            "scala_proto_rules_scalapb_compilerplugin",
            "scala_proto_rules_scalapb_lenses",
            "scala_proto_rules_scalapb_protoc_bridge",
            "scala_proto_rules_scalapb_runtime",
            "scala_proto_rules_scalapb_runtime_grpc",
        ],
        maven_servers = maven_servers,
        fetch_sources = True,
        overriden_artifacts = overriden_artifacts,
    )

    native.register_toolchains("@io_bazel_rules_scala//scala_proto:default_deps_toolchain")
