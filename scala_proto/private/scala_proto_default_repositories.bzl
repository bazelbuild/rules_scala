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
        maven_servers = ["http://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    native.maven_server(
        name = "scala_proto_deps_maven_server",
        url = "http://central.maven.org/maven2/",
    )

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

    native.maven_jar(
        name = "scala_proto_rules_grpc_core",
        artifact = "io.grpc:grpc-core:1.19.0",
        sha1 = "48b280ef2c8f42989c65bd61665926c212379660",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.19.0",
        sha1 = "f9c61fb98a0d5617c430ff3313171072a5b4bca1",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.19.0",
        sha1 = "21964ce4b695d50e826c93b362f2c710d57028ae",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.19.0",
        sha1 = "315399f4d3b6df530ab038e7ec29a1f18f3b832a",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.19.0",
        sha1 = "bb73958187106ef1300b9e47ce5333f40cb913eb",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_guava",
        # io.grpc:grpc-core:1.19.0 defines a dependency on guava 26.0-android
        # see https://search.maven.org/artifact/io.grpc/grpc-core/1.19.0/jar
        artifact = "com.google.guava:guava:26.0-android",
        sha1 = "ef69663836b339db335fde0df06fb3cd84e3742b",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/guava",
        actual = "@scala_proto_rules_guava//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_google_instrumentation",
        artifact = "com.google.instrumentation:instrumentation-api:0.3.0",
        sha1 = "a2e145e7a7567c6372738f5c5a6f3ba6407ac354",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/google_instrumentation",
        actual = "@scala_proto_rules_google_instrumentation//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec",
        artifact = "io.netty:netty-codec:4.1.32.Final",
        sha1 = "8f32bd79c5a16f014a4372ed979dc62b39ede33a",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec",
        actual = "@scala_proto_rules_netty_codec//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http",
        artifact = "io.netty:netty-codec-http:4.1.32.Final",
        sha1 = "0b9218adba7353ad5a75fcb639e4755d64bd6ddf",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http",
        actual = "@scala_proto_rules_netty_codec_http//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_socks",
        artifact = "io.netty:netty-codec-socks:4.1.32.Final",
        sha1 = "b1e83cb772f842839dbeebd9a1f053da98bf56d2",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_socks",
        actual = "@scala_proto_rules_netty_codec_socks//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http2",
        artifact = "io.netty:netty-codec-http2:4.1.32.Final",
        sha1 = "d14eb053a1f96d3330ec48e77d489118d547557a",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http2",
        actual = "@scala_proto_rules_netty_codec_http2//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler",
        artifact = "io.netty:netty-handler:4.1.32.Final",
        sha1 = "b4e3fa13f219df14a9455cc2111f133374428be0",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler",
        actual = "@scala_proto_rules_netty_handler//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_buffer",
        artifact = "io.netty:netty-buffer:4.1.32.Final",
        sha1 = "046ede57693788181b2cafddc3a5967ed2f621c8",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_buffer",
        actual = "@scala_proto_rules_netty_buffer//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_transport",
        artifact = "io.netty:netty-transport:4.1.32.Final",
        sha1 = "d5e5a8ff9c2bc7d91ddccc536a5aca1a4355bd8b",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_transport",
        actual = "@scala_proto_rules_netty_transport//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_resolver",
        artifact = "io.netty:netty-resolver:4.1.32.Final",
        sha1 = "3e0114715cb125a12db8d982b2208e552a91256d",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_resolver",
        actual = "@scala_proto_rules_netty_resolver//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_common",
        artifact = "io.netty:netty-common:4.1.32.Final",
        sha1 = "e95de4f762606f492328e180c8ad5438565a5e3b",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_common",
        actual = "@scala_proto_rules_netty_common//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler_proxy",
        artifact = "io.netty:netty-handler-proxy:4.1.32.Final",
        sha1 = "58b621246262127b97a871b88c09374c8c324cb7",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
        actual = "@scala_proto_rules_netty_handler_proxy//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_opencensus_api",
        artifact = "io.opencensus:opencensus-api:0.18.0",
        sha1 = "b89a8f8dfd1e1e0d68d83c82a855624814b19a6e",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_api",
        actual = "@scala_proto_rules_opencensus_api//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_opencensus_contrib_grpc_metrics",
        artifact = "io.opencensus:opencensus-contrib-grpc-metrics:0.18.0",
        sha1 = "8e90fab2930b6a0e67dab48911b9c936470d43dd",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/opencensus_contrib_grpc_metrics",
        actual = "@scala_proto_rules_opencensus_contrib_grpc_metrics//jar",
    )
