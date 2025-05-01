# Needed by scalafmt
SCALAPB_COMPILE_ARTIFACT_IDS = [
    "com_google_protobuf_protobuf_java",
    "com_lihaoyi_fastparse",
    "com_lihaoyi_sourcecode",
    "scala_proto_rules_scalapb_lenses",
    "scala_proto_rules_scalapb_runtime",
]

# Needed by twitter_scrooge
GUAVA_ARTIFACT_IDS = [
    "com_google_code_findbugs_jsr305",
    "com_google_errorprone_error_prone_annotations",
    "com_google_j2objc_j2objc_annotations",
    "io_bazel_rules_scala_guava",
    "io_bazel_rules_scala_failureaccess",
    "org_checkerframework_checker_qual",
    "org_jspecify_jspecify",
]

def scala_proto_artifact_ids(scala_version):
    return ([] if scala_version.startswith("2.11.") else [
        "dev_dirs_directories",
        "scala_proto_rules_scalapb_protoc_gen",
    ]) + [
        "com_google_android_annotations",
        "com_google_code_gson_gson",
        "org_codehaus_mojo_animal_sniffer_annotations",
        "scala_proto_rules_disruptor",
        "scala_proto_rules_grpc_api",
        "scala_proto_rules_grpc_context",
        "scala_proto_rules_grpc_core",
        "scala_proto_rules_grpc_netty",
        "scala_proto_rules_grpc_protobuf",
        "scala_proto_rules_grpc_protobuf_lite",
        "scala_proto_rules_grpc_stub",
        "scala_proto_rules_grpc_util",
        "scala_proto_rules_instrumentation_api",
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
        "scala_proto_rules_netty_transport_native_unix_common",
        "scala_proto_rules_opencensus_api",
        "scala_proto_rules_opencensus_contrib_grpc_metrics",
        "scala_proto_rules_opencensus_impl",
        "scala_proto_rules_opencensus_impl_core",
        "scala_proto_rules_perfmark_api",
        "scala_proto_rules_proto_google_common_protos",
        "scala_proto_rules_scalapb_compilerplugin",
        "scala_proto_rules_scalapb_protoc_bridge",
        "scala_proto_rules_scalapb_runtime_grpc",
    ] + SCALAPB_COMPILE_ARTIFACT_IDS + GUAVA_ARTIFACT_IDS
