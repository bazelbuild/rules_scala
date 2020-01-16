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

def scala_proto_default_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["https://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "scalapb_plugin": "b67e563d06f1bbb6ea704a063760a85ec7fb5809828402364d5418dd1c5cab06",
            "protoc_bridge": "e94cf50d9ba4b3d5f4b491cb9483b4da566afe24d0fa809a003263b4b50ff269",
            "scalapbc": "120b7d7f42051da3406b72480eeb331a985a99b2a3c999243fc3c11e6b7530b2",
            "scalapb_runtime": "40f93a9ec5ea4dc21e1fa4fb4088cf76768dd3c0137c3fa6683ae0d9a17f5d44",
            "scalapb_runtime_grpc": "93a9f5f1c64ef83aacc2e46c9c09f3156f59d979b5b5565eac9437897882c465",
            "scalapb_lenses": "bacdee7d8b6fa7a822a3ec55d12a15896d54fe2e4f22bbd8a5194e9bba751193",
            "scalapb_fastparse": "1b6d9fc75ca8a62abe0dd7a71e62aa445f2d3198c86aab5088e1f90a96ade30b",
        },
        "2.12": {
            "scalapb_plugin": "5df9d1ceb3d67ad0cd2de561e7f0e0fc77cf08d305d1a0e21a2f4f135efe76a9",
            "protoc_bridge": "6b83ac0be522bf868fcbab27c2b64286912924f1cdbc17e0e12e092abff8bdc5",
            "scalapbc": "4a986c7f7447aa2e8cd4be4329c2aa2a42ebdfc8135c6882bef958a527ea7667",
            "scalapb_runtime": "82596e3235f8ccda30fbd6290e0ba314ba880283874658fc876217701d3ef5e4",
            "scalapb_runtime_grpc": "e5bb54164581d44ea2b2221b5546880deb7073b1d02b56da8f666454f3a14387",
            "scalapb_lenses": "79100162924477084ac2ab35b02067ee875e5dade58a33e882ec9f2900418de3",
            "scalapb_fastparse": "1227a00a26a4ad76ddcfa6eae2416687df7f3c039553d586324b32ba0a528fcc",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_plugin",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:compilerplugin:0.8.4",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapb_plugin"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_plugin",
        actual = "@scala_proto_rules_scalapb_plugin",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_protoc_bridge",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:protoc-bridge:0.7.3",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["protoc_bridge"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/protoc_bridge",
        actual = "@scala_proto_rules_protoc_bridge",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapbc",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:scalapbc:0.8.4",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapbc"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapbc",
        actual = "@scala_proto_rules_scalapbc",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_runtime",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:scalapb-runtime:0.8.4",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapb_runtime"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_runtime",
        actual = "@scala_proto_rules_scalapb_runtime",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_runtime_grpc",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:scalapb-runtime-grpc:0.8.4",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapb_runtime_grpc"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_runtime_grpc",
        actual = "@scala_proto_rules_scalapb_runtime_grpc",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_lenses",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:lenses:0.8.4",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapb_lenses"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_lenses",
        actual = "@scala_proto_rules_scalapb_lenses",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_fastparse",
        artifact = _scala_mvn_artifact(
            "com.lihaoyi:fastparse:1.0.0",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalapb_fastparse"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_fastparse",
        actual = "@scala_proto_rules_scalapb_fastparse",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_core",
        artifact = "io.grpc:grpc-core:1.19.0",
        jar_sha256 = "3cfaae2db268e4da2609079cecade8434afcb7ab23a126a57d870b722b2b6ab9",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.19.0",
        jar_sha256 = "711dad5734b4e8602a271cb383eda504d6d1bf5385ced045a0ca91176ae73821",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.19.0",
        jar_sha256 = "37e50ab7de4a50db4c9f9a2f095ffc51df49e36c9ab7fffb1f3ad20ab6f47022",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.19.0",
        jar_sha256 = "08604191fa77ef644cd9d7323d633333eceb800831805395a21b5c8e7d02caf0",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.19.0",
        jar_sha256 = "8f4df8618c500f3c1fdf88b755caeb14fe2846ea59a9e762f614852178b64318",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_guava",
        # io.grpc:grpc-core:1.19.0 defines a dependency on guava 26.0-android
        # see https://search.maven.org/artifact/io.grpc/grpc-core/1.19.0/jar
        artifact = "com.google.guava:guava:26.0-android",
        jar_sha256 = "1d044ebb866ef08b7d04e998b4260c9b52fab6e6d6b68d207859486bb3686cd5",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/guava",
        actual = "@scala_proto_rules_guava//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_google_instrumentation",
        artifact = "com.google.instrumentation:instrumentation-api:0.3.0",
        jar_sha256 = "671f7147487877f606af2c7e39399c8d178c492982827305d3b1c7f5b04f1145",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/google_instrumentation",
        actual = "@scala_proto_rules_google_instrumentation//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_codec",
        artifact = "io.netty:netty-codec:4.1.32.Final",
        jar_sha256 = "dbd6cea7d7bf5a2604e87337cb67c9468730d599be56511ed0979aacb309f879",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec",
        actual = "@scala_proto_rules_netty_codec//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_codec_http",
        artifact = "io.netty:netty-codec-http:4.1.32.Final",
        jar_sha256 = "db2c22744f6a4950d1817e4e1a26692e53052c5d54abe6cceecd7df33f4eaac3",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http",
        actual = "@scala_proto_rules_netty_codec_http//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_codec_socks",
        artifact = "io.netty:netty-codec-socks:4.1.32.Final",
        jar_sha256 = "fe2f2e97d6c65dc280623dcfd24337d8a5c7377049c120842f2c59fb83d7408a",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_socks",
        actual = "@scala_proto_rules_netty_codec_socks//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_codec_http2",
        artifact = "io.netty:netty-codec-http2:4.1.32.Final",
        jar_sha256 = "4d4c6cfc1f19efb969b9b0ae6cc977462d202867f7dcfee6e9069977e623a2f5",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http2",
        actual = "@scala_proto_rules_netty_codec_http2//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_handler",
        artifact = "io.netty:netty-handler:4.1.32.Final",
        jar_sha256 = "07d9756e48b5f6edc756e33e8b848fb27ff0b1ae087dab5addca6c6bf17cac2d",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler",
        actual = "@scala_proto_rules_netty_handler//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_buffer",
        artifact = "io.netty:netty-buffer:4.1.32.Final",
        jar_sha256 = "8ac0e30048636bd79ae205c4f9f5d7544290abd3a7ed39d8b6d97dfe3795afc1",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_buffer",
        actual = "@scala_proto_rules_netty_buffer//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_transport",
        artifact = "io.netty:netty-transport:4.1.32.Final",
        jar_sha256 = "175bae0d227d7932c0c965c983efbb3cf01f39abe934f5c4071d0319784715fb",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_transport",
        actual = "@scala_proto_rules_netty_transport//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_resolver",
        artifact = "io.netty:netty-resolver:4.1.32.Final",
        jar_sha256 = "9b4a19982047a95ea4791a7ad7ad385c7a08c2ac75f0a3509cc213cb32a726ae",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_resolver",
        actual = "@scala_proto_rules_netty_resolver//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_common",
        artifact = "io.netty:netty-common:4.1.32.Final",
        jar_sha256 = "cc993e660f8f8e3b033f1d25a9e2f70151666bdf878d460a6508cb23daa696dc",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_common",
        actual = "@scala_proto_rules_netty_common//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_netty_handler_proxy",
        artifact = "io.netty:netty-handler-proxy:4.1.32.Final",
        jar_sha256 = "10d1081ed114bb0e76ebbb5331b66a6c3189cbdefdba232733fc9ca308a6ea34",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
        actual = "@scala_proto_rules_netty_handler_proxy//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_api",
        artifact = "io.opencensus:opencensus-api:0.18.0",
        jar_sha256 = "45421ffe95271aba94686ed8d4c5070fe77dc2ff0b922688097f0dd40f1931b1",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_api",
        actual = "@scala_proto_rules_opencensus_api//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_contrib_grpc_metrics",
        artifact = "io.opencensus:opencensus-contrib-grpc-metrics:0.18.0",
        jar_sha256 = "1f90585e777b1e0493dbf22e678303369a8d5b7c750b4eda070a34ca99271607",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_contrib_grpc_metrics",
        actual = "@scala_proto_rules_opencensus_contrib_grpc_metrics//jar",
    )
