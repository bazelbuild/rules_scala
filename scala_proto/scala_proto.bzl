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

def scala_proto_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    native.maven_server(
        name = "scala_proto_deps_maven_server",
        url = "http://central.maven.org/maven2/",
    )

    native.maven_jar(
        name = "scala_proto_rules_protoc_jar",
        artifact = "com.github.os72:protoc-jar:3.6.0",
        sha1 = "3cd7fa5bec9b11104468c72934773e5820e1c89e",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/protoc",
        actual = "@scala_proto_rules_protoc_jar//jar",
    )

    scala_jar_shas = {
        "2.11": {
            "scalapb_plugin": "10ca2ad448f69013aa453a984f0ab7431fc0dbae158f4fc21dc7739f610345e3",
            "protoc_bridge": "e94cf50d9ba4b3d5f4b491cb9483b4da566afe24d0fa809a003263b4b50ff269",
            "scalapbc": "af1aa0c243987bfdbf19eb8ddbaf9351a5c5a2e4fce99a1bfdf33d04938b2889",
            "scalapb_runtime": "73c64f3b9c43fa896fc5d5e42bc1a3e941e2bc106d990b4ea8623116b0639917",
            "scalapb_runtime_grpc": "88d62342b607f8f74cd262a5e4565ff4652eb1fa20e370f20fd816a89861e2a0",
            "scalapb_lenses": "853cf830cbd6bb43e42331bf1ea5f259ef6c7085af80254bd9cd20b21f17826b",
            "scalapb_fastparse": "9e07298f20ee37e828f2699b71b447008ebf122cc86cab1d1fcd8d00fad4837b",
        },
        "2.12": {
            "scalapb_plugin": "a6ae7bc5108c40075082c9eaca68443efd8f496a7f3ee33ba2192fd36b74fb09",
            "protoc_bridge": "6b83ac0be522bf868fcbab27c2b64286912924f1cdbc17e0e12e092abff8bdc5",
            "scalapbc": "2c01d631d33bc4cbb1dba0d621b904044ad37a10dbc0be18caf399c8e15d7732",
            "scalapb_runtime": "d8177cc6ccdeafa7659fe798401fee93929d879c196eb690a236b95eb272c711",
            "scalapb_runtime_grpc": "6c2c7332535b1a065b3207dc4d8314c846cbd29d296aaba0c2b57505489a6cc0",
            "scalapb_lenses": "c3b5d16dd27a44c2a67d98e47fc9a3180c1eedcaedda36b49f87b4ac321e412a",
            "scalapb_fastparse": "7bc2a3131204e737f020f94e19b1e62a1bf5359f5741c35dff9351ef36d7a80e",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

    _scala_maven_import_external(
        name = "scala_proto_rules_scalapb_plugin",
        artifact = _scala_mvn_artifact(
            "com.thesamet.scalapb:compilerplugin:0.7.0",
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
            "com.thesamet.scalapb:scalapbc:0.7.0",
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
            "com.thesamet.scalapb:scalapb-runtime:0.7.0",
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
            "com.thesamet.scalapb:scalapb-runtime-grpc:0.7.0",
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
            "com.thesamet.scalapb:lenses:0.7.0",
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
            "com.lihaoyi:fastparse:0.4.4",
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
        artifact = "io.grpc:grpc-core:1.3.1",
        sha1 = "a9b38b4a19af3ef208f4f6bf7871876d959c5eb1",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.3.1",
        sha1 = "60bdfa9d8c664a9d87ae461106eff6eed8da6c54",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.3.1",
        sha1 = "9562e977cacd6e128a31686c3e6948d61873c496",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.3.1",
        sha1 = "cc3831fccb76cfe21445f75cc055b5ffd979dc54",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.3.1",
        sha1 = "28accd419b18d59055b8999f78f5cb7767c7bde8",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_guava",
        artifact = "com.google.guava:guava:19.0",
        sha1 = "6ce200f6b23222af3d8abb6b6459e6c44f4bb0e9",
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
        artifact = "io.netty:netty-codec:4.1.8.Final",
        sha1 = "1bd0a2d032e5c7fc3f42c1b483d0f4c57eb516a3",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec",
        actual = "@scala_proto_rules_netty_codec//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http",
        artifact = "io.netty:netty-codec-http:4.1.8.Final",
        sha1 = "1e88617c4a6c88da7e86fdbbd9494d22a250c879",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http",
        actual = "@scala_proto_rules_netty_codec_http//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_socks",
        artifact = "io.netty:netty-codec-socks:4.1.8.Final",
        sha1 = "7f7c5f5b154646d7c571f8ca944fb813f71b1d51",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_socks",
        actual = "@scala_proto_rules_netty_codec_socks//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http2",
        artifact = "io.netty:netty-codec-http2:4.1.8.Final",
        sha1 = "105a99ee5767463370ccc3d2e16800bd99f5648e",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_codec_http2",
        actual = "@scala_proto_rules_netty_codec_http2//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler",
        artifact = "io.netty:netty-handler:4.1.8.Final",
        sha1 = "db01139bfb11afd009a695eef55b43bbf22c4ef5",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler",
        actual = "@scala_proto_rules_netty_handler//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_buffer",
        artifact = "io.netty:netty-buffer:4.1.8.Final",
        sha1 = "43292c2622e340a0d07178c341ca3bdf3d662034",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_buffer",
        actual = "@scala_proto_rules_netty_buffer//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_transport",
        artifact = "io.netty:netty-transport:4.1.8.Final",
        sha1 = "905b5dadce881c9824b3039c0df36dabbb7b6a07",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_transport",
        actual = "@scala_proto_rules_netty_transport//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_resolver",
        artifact = "io.netty:netty-resolver:4.1.8.Final",
        sha1 = "2e116cdd5edc01b2305072b1dbbd17c0595dbfef",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_resolver",
        actual = "@scala_proto_rules_netty_resolver//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_common",
        artifact = "io.netty:netty-common:4.1.8.Final",
        sha1 = "ee62c80318413d2375d145e51e48d7d35c901324",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_common",
        actual = "@scala_proto_rules_netty_common//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler_proxy",
        artifact = "io.netty:netty-handler-proxy:4.1.8.Final",
        sha1 = "c4d22e8b9071a0ea8d75766d869496c32648a758",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
        actual = "@scala_proto_rules_netty_handler_proxy//jar",
    )

def _root_path(f):
    if f.is_source:
        return f.owner.workspace_root
    return "/".join([f.root.path, f.owner.workspace_root])

def _colon_paths(data):
    return ":".join([
        "{root},{path}".format(root = _root_path(f), path = f.path)
        for f in sorted(data)
    ])

def _gen_proto_srcjar_impl(ctx):
    acc_imports = []
    transitive_proto_paths = []

    jvm_deps = []
    for target in ctx.attr.deps:
        if hasattr(target, "proto"):
            acc_imports.append(target.proto.transitive_sources)
            transitive_proto_paths.append(target.proto.transitive_proto_path)
        else:
            jvm_deps.append(target)

    acc_imports = depset(transitive = acc_imports)
    if "java_conversions" in ctx.attr.flags and len(jvm_deps) == 0:
        fail(
            "must have at least one jvm dependency if with_java is True (java_conversions is turned on)",
        )

    deps_jars = collect_jars(jvm_deps)

    blacklisted_protos = [dep for target in ctx.attr.blacklisted_protos for dep in target.proto.transitive_sources]
    blacklisted_protos_dict = dict(zip(blacklisted_protos, blacklisted_protos))
    inputs = [f.path for f in sorted(acc_imports) if blacklisted_protos_dict.get(f, None) == None]

    worker_content = "{output}\n{paths}\n{flags_arg}\n{packages}\n{inputs}".format(
        output = ctx.outputs.srcjar.path,
        paths = _colon_paths(acc_imports.to_list()),
        # Command line args to worker cannot be empty so using padding
        flags_arg = "-" + ",".join(ctx.attr.flags),
        # Command line args to worker cannot be empty so using padding
        packages = "-" +
                   ":".join(depset(transitive = transitive_proto_paths).to_list()),
        inputs = ":".join(inputs)
    )
    argfile = ctx.actions.declare_file(
        "%s_worker_input" % ctx.label.name,
        sibling = ctx.outputs.srcjar,
    )
    ctx.actions.write(output = argfile, content = worker_content)
    ctx.actions.run(
        executable = ctx.executable.generator,
        inputs = depset([argfile], transitive = [acc_imports]),
        outputs = [ctx.outputs.srcjar],
        mnemonic = "ProtoScalaPBRule",
        progress_message = "creating scalapb files %s" % ctx.label,
        execution_requirements = {"supports-workers": "1"},
        arguments = ["@" + argfile.path],
    )
    srcjarsattr = struct(srcjar = ctx.outputs.srcjar)
    scalaattr = struct(
        outputs = None,
        compile_jars = deps_jars.compile_jars,
        transitive_runtime_jars = deps_jars.transitive_runtime_jars,
    )
    java_provider = create_java_provider(scalaattr, depset())
    return struct(
        scala = scalaattr,
        providers = [java_provider],
        srcjars = srcjarsattr,
    )

scala_proto_srcjar = rule(
    _gen_proto_srcjar_impl,
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [["proto"],[JavaInfo]],
        ),
        "flags": attr.string_list(default = []),
        "generator": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
        ),
        "blacklisted_protos" : attr.label_list(providers = [["proto"]]),
    },
    outputs = {
        "srcjar": "lib%{name}.srcjar",
    },
)

SCALAPB_DEPS = [
    "//external:io_bazel_rules_scala/dependency/proto/scalapb_runtime",
    "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
    "//external:io_bazel_rules_scala/dependency/proto/scalapb_lenses",
    "//external:io_bazel_rules_scala/dependency/proto/scalapb_fastparse",
]

GRPC_DEPS = [
    "//external:io_bazel_rules_scala/dependency/proto/scalapb_runtime_grpc",
    "//external:io_bazel_rules_scala/dependency/proto/grpc_core",
    "//external:io_bazel_rules_scala/dependency/proto/grpc_stub",
    "//external:io_bazel_rules_scala/dependency/proto/grpc_protobuf",
    "//external:io_bazel_rules_scala/dependency/proto/grpc_netty",
    "//external:io_bazel_rules_scala/dependency/proto/grpc_context",
    "//external:io_bazel_rules_scala/dependency/proto/guava",
    "//external:io_bazel_rules_scala/dependency/proto/google_instrumentation",
    "//external:io_bazel_rules_scala/dependency/proto/netty_codec",
    "//external:io_bazel_rules_scala/dependency/proto/netty_codec_http",
    "//external:io_bazel_rules_scala/dependency/proto/netty_codec_http2",
    "//external:io_bazel_rules_scala/dependency/proto/netty_codec_socks",
    "//external:io_bazel_rules_scala/dependency/proto/netty_handler",
    "//external:io_bazel_rules_scala/dependency/proto/netty_buffer",
    "//external:io_bazel_rules_scala/dependency/proto/netty_transport",
    "//external:io_bazel_rules_scala/dependency/proto/netty_resolver",
    "//external:io_bazel_rules_scala/dependency/proto/netty_common",
    "//external:io_bazel_rules_scala/dependency/proto/netty_handler_proxy",
]
"""Generate scalapb bindings for a set of proto_library targets.

Example:
    scalapb_proto_library(
        name = "exampla_proto_scala",
        with_grpc = True,
        deps = ["//src/proto:example_service"]
    )

Args:
    name: A unique name for this rule
    deps: Proto library or java proto library (if with_java is True) targets that this rule depends on
    with_grpc: Enables generation of grpc service bindings for services defined in deps
    with_java: Enables generation of converters to and from java protobuf bindings
    with_flat_package: When true, ScalaPB will not append the protofile base name to the package name
    with_single_line_to_string: Enables generation of toString() methods that use the single line format

Outputs:
    A scala_library rule that includes the generated scalapb bindings, as
    well as any library dependencies needed to compile and use these.
"""

def scalapb_proto_library(
        name,
        deps = [],
        with_grpc = False,
        with_java = False,
        with_flat_package = False,
        with_single_line_to_string = False,
        visibility = None):
    srcjar = name + "_srcjar"
    flags = []
    if with_grpc:
        flags.append("grpc")
    if with_java:
        flags.append("java_conversions")
    if with_flat_package:
        flags.append("flat_package")
    if with_single_line_to_string:
        flags.append("single_line_to_string")
    scala_proto_srcjar(
        name = srcjar,
        flags = flags,
        generator = "@io_bazel_rules_scala//src/scala/scripts:scalapb_generator",
        deps = deps,
        visibility = visibility,
    )

    external_deps = list(SCALAPB_DEPS + GRPC_DEPS if (
        with_grpc
    ) else SCALAPB_DEPS)

    scala_library(
        name = name,
        deps = [srcjar] + external_deps,
        unused_dependency_checker_ignored_targets = [srcjar] + external_deps,
        exports = external_deps,
        visibility = visibility,
    )
