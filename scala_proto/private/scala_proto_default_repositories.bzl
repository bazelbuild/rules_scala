load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _default_scala_version = "default_scala_version",
    _scala_mvn_artifact = "scala_mvn_artifact",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def scala_proto_default_repositories(
        scala_version = _default_scala_version(),
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    repositories(
        for_artifact_ids = [
            "scala_proto_rules_scalapb_plugin",
            "scala_proto_rules_protoc_bridge",
            "scala_proto_rules_scalapb_runtime",
            "scala_proto_rules_scalapb_runtime_grpc",
            "scala_proto_rules_scalapb_lenses",
            "scala_proto_rules_scalapb_fastparse",
            "scala_proto_rules_grpc_core",
            "scala_proto_rules_grpc_api",
            "scala_proto_rules_grpc_stub",
            "scala_proto_rules_grpc_protobuf",
            "scala_proto_rules_grpc_netty",
            "scala_proto_rules_grpc_context",
            "scala_proto_rules_perfmark_api",
            "scala_proto_rules_guava",
            "scala_proto_rules_google_instrumentation",
            "scala_proto_rules_netty_codec",
            "scala_proto_rules_netty_codec_http",
            "scala_proto_rules_netty_codec_socks",
            "scala_proto_rules_netty_codec_http2",
            "scala_proto_rules_netty_handler",
            "scala_proto_rules_netty_buffer",
            "scala_proto_rules_netty_transport",
            "scala_proto_rules_netty_resolver",
            "scala_proto_rules_netty_common",
            "scala_proto_rules_netty_handler_proxy",
            "scala_proto_rules_opencensus_api",
            "scala_proto_rules_opencensus_impl",
            "scala_proto_rules_disruptor",
            "scala_proto_rules_opencensus_impl_core",
            "scala_proto_rules_opencensus_contrib_grpc_metrics",
        ],
        scala_version = scala_version,
        maven_servers = maven_servers,
        fetch_sources = True,
        overriden_artifacts = overriden_artifacts,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_plugin",
        actual = "@scala_proto_rules_scalapb_plugin",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/protoc_bridge",
        actual = "@scala_proto_rules_protoc_bridge",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_runtime",
        actual = "@scala_proto_rules_scalapb_runtime",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_runtime_grpc",
        actual = "@scala_proto_rules_scalapb_runtime_grpc",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_lenses",
        actual = "@scala_proto_rules_scalapb_lenses",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_fastparse",
        actual = "@scala_proto_rules_scalapb_fastparse",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_api",
        actual = "@scala_proto_rules_grpc_api//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/perfmark_api",
        actual = "@scala_proto_rules_perfmark_api//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/guava",
        actual = "@scala_proto_rules_guava//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/google_instrumentation",
        actual = "@scala_proto_rules_google_instrumentation//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec",
        actual = "@scala_proto_rules_netty_codec//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http",
        actual = "@scala_proto_rules_netty_codec_http//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_socks",
        actual = "@scala_proto_rules_netty_codec_socks//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http2",
        actual = "@scala_proto_rules_netty_codec_http2//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler",
        actual = "@scala_proto_rules_netty_handler//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_buffer",
        actual = "@scala_proto_rules_netty_buffer//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_transport",
        actual = "@scala_proto_rules_netty_transport//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_resolver",
        actual = "@scala_proto_rules_netty_resolver//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_common",
        actual = "@scala_proto_rules_netty_common//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
        actual = "@scala_proto_rules_netty_handler_proxy//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_api",
        actual = "@scala_proto_rules_opencensus_api//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_impl",
        actual = "@scala_proto_rules_opencensus_impl//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/disruptor",
        actual = "@scala_proto_rules_disruptor//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_impl_core",
        actual = "@scala_proto_rules_opencensus_impl_core//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_contrib_grpc_metrics",
        actual = "@scala_proto_rules_opencensus_contrib_grpc_metrics//jar",
    )
