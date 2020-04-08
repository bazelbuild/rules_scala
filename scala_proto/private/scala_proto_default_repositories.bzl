load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
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
        maven_servers = _default_maven_server_urls()):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "scalapb_plugin": "2d6793fa2565953ef2b5094fc37fae4933f3c42e4cb4048d54e7f358ec104a87",
            "protoc_bridge": "314e34bf331b10758ff7a780560c8b5a5b09e057695a643e33ab548e3d94aa03",
            "scalapbc": "dd92db48d395b54de53297aa13f2666ab314540fe2c83e923d2cbd80f0c79541",
            "scalapb_runtime": "5131033e9536727891a38004ec707a93af1166cb8283c7db711c2c105fbf289e",
            "scalapb_runtime_grpc": "24d19df500ce6450d8f7aa72a9bad675fa4f3650f7736d548aa714058f887e23",
            "scalapb_lenses": "f8e3b526ceac998652b296014e9ab4c0ab906a40837dd1dfcf6948b6f5a1a8bf",
            "scalapb_fastparse": "5c5d81f90ada03ac5b21b161864a52558133951031ee5f6bf4d979e8baa03628",
        },
        "2.12": {
            "scalapb_plugin": "516ed567e2c3ac28b91a2f350d3febc7a6a396978718145f536853ffe8de40c2",
            "protoc_bridge": "2b8db0b71be5052768a96ccc41c9bb03f3f19e1e267e810a64963566538b1a2b",
            "scalapbc": "5c2e8188f3c7c5e9528fdd648cd5dce9a91fcbecb5c3c022a50dd5df2d57511b",
            "scalapb_runtime": "82624a7fadaa323bbb8d33e37f055ce42e761c203573ace3ccf95bd0511917fe",
            "scalapb_runtime_grpc": "4c00f2a57cc1d00a2d454f695c3f1e565173e1d1297294f1cf81339bdeba3f4a",
            "scalapb_lenses": "fff4fc9d47ad44c1371ff2d8dfa2b5907826c4b98ca576baf67f14d31d0d9be1",
            "scalapb_fastparse": "e8b831a843c0eb5105d42e4b6febfc772b3aed3a853a899e6c8196e9ecc057df",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_plugin",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:compilerplugin:0.9.7",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapb_plugin"],
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
            "com.thesamet.scalapb:protoc-bridge:0.7.14",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["protoc_bridge"],
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
            "com.thesamet.scalapb:scalapbc:0.9.7",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapbc"],
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
            "com.thesamet.scalapb:scalapb-runtime:0.9.7",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapb_runtime"],
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
            "com.thesamet.scalapb:scalapb-runtime-grpc:0.9.7",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapb_runtime_grpc"],
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
            "com.thesamet.scalapb:lenses:0.9.7",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapb_lenses"],
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
            "com.lihaoyi:fastparse:" + ("2.1.2" if int(scala_version.split(".")[1]) < 12 else "2.1.3"),
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalapb_fastparse"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/scalapb_fastparse",
        actual = "@scala_proto_rules_scalapb_fastparse",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_core",
        artifact = "io.grpc:grpc-core:1.24.0",
        artifact_sha256 = "8fc900625a9330b1c155b5423844d21be0a5574fe218a63170a16796c6f7880e",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_api",
        artifact = "io.grpc:grpc-api:1.24.0",
        artifact_sha256 = "553978366e04ee8ddba64afde3b3cf2ac021a2f3c2db2831b6491d742b558598",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_api",
        actual = "@scala_proto_rules_grpc_api//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.24.0",
        artifact_sha256 = "eaa9201896a77a0822e26621b538c7154f00441a51c9b14dc9e1ec1f2acfb815",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.24.0",
        artifact_sha256 = "88cd0838ea32893d92cb214ea58908351854ed8de7730be07d5f7d19025dd0bc",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.24.0",
        artifact_sha256 = "8478333706ba442a354c2ddb8832d80a5aef71016e8a9cf07e7bf6e8c298f042",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.24.0",
        artifact_sha256 = "1f0546e18789f7445d1c5a157010a11bc038bbb31544cdb60d9da3848efcfeea",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_perfmark_api",
        artifact = "io.perfmark:perfmark-api:0.17.0",
        artifact_sha256 = "816c11409b8a0c6c9ce1cda14bed526e7b4da0e772da67c5b7b88eefd41520f9",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/perfmark_api",
        actual = "@scala_proto_rules_perfmark_api//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_guava",
        # io.grpc:grpc-api:1.24.0 defines a dependency on guava 26.0-android
        # see https://search.maven.org/artifact/io.grpc/grpc-api/1.24.0/jar
        artifact = "com.google.guava:guava:26.0-android",
        artifact_sha256 = "1d044ebb866ef08b7d04e998b4260c9b52fab6e6d6b68d207859486bb3686cd5",
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
        artifact_sha256 = "671f7147487877f606af2c7e39399c8d178c492982827305d3b1c7f5b04f1145",
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
        artifact_sha256 = "dbd6cea7d7bf5a2604e87337cb67c9468730d599be56511ed0979aacb309f879",
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
        artifact_sha256 = "db2c22744f6a4950d1817e4e1a26692e53052c5d54abe6cceecd7df33f4eaac3",
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
        artifact_sha256 = "fe2f2e97d6c65dc280623dcfd24337d8a5c7377049c120842f2c59fb83d7408a",
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
        artifact_sha256 = "4d4c6cfc1f19efb969b9b0ae6cc977462d202867f7dcfee6e9069977e623a2f5",
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
        artifact_sha256 = "07d9756e48b5f6edc756e33e8b848fb27ff0b1ae087dab5addca6c6bf17cac2d",
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
        artifact_sha256 = "8ac0e30048636bd79ae205c4f9f5d7544290abd3a7ed39d8b6d97dfe3795afc1",
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
        artifact_sha256 = "175bae0d227d7932c0c965c983efbb3cf01f39abe934f5c4071d0319784715fb",
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
        artifact_sha256 = "9b4a19982047a95ea4791a7ad7ad385c7a08c2ac75f0a3509cc213cb32a726ae",
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
        artifact_sha256 = "cc993e660f8f8e3b033f1d25a9e2f70151666bdf878d460a6508cb23daa696dc",
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
        artifact_sha256 = "10d1081ed114bb0e76ebbb5331b66a6c3189cbdefdba232733fc9ca308a6ea34",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
        actual = "@scala_proto_rules_netty_handler_proxy//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_api",
        artifact = "io.opencensus:opencensus-api:0.22.1",
        artifact_sha256 = "62a0503ee81856ba66e3cde65dee3132facb723a4fa5191609c84ce4cad36127",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_api",
        actual = "@scala_proto_rules_opencensus_api//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_impl",
        artifact = "io.opencensus:opencensus-impl:0.22.1",
        artifact_sha256 = "9e8b209da08d1f5db2b355e781b9b969b2e0dab934cc806e33f1ab3baed4f25a",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_impl",
        actual = "@scala_proto_rules_opencensus_impl//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_disruptor",
        artifact = "com.lmax:disruptor:3.4.2",
        artifact_sha256 = "f412ecbb235c2460b45e63584109723dea8d94b819c78c9bfc38f50cba8546c0",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/disruptor",
        actual = "@scala_proto_rules_disruptor//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_impl_core",
        artifact = "io.opencensus:opencensus-impl-core:0.22.1",
        artifact_sha256 = "04607d100e34bacdb38f93c571c5b7c642a1a6d873191e25d49899668514db68",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_impl_core",
        actual = "@scala_proto_rules_opencensus_impl_core//jar",
    )

    _scala_maven_import_external(
        name = "scala_proto_rules_opencensus_contrib_grpc_metrics",
        artifact = "io.opencensus:opencensus-contrib-grpc-metrics:0.22.1",
        artifact_sha256 = "3f6f4d5bd332c516282583a01a7c940702608a49ed6e62eb87ef3b1d320d144b",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_contrib_grpc_metrics",
        actual = "@scala_proto_rules_opencensus_contrib_grpc_metrics//jar",
    )
