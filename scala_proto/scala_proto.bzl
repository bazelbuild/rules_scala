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
        artifact = "com.github.os72:protoc-jar:3.6.0.1",
        sha1 = "db8a7cc739f5b332e7f32fd5dfacae68f0062581",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/protoc",
        actual = "@scala_proto_rules_protoc_jar//jar",
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
        artifact = "io.grpc:grpc-core:1.18.0",
        sha1 = "e21b343bba2006bac31bb16b7438701cddfbf564",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_core",
        actual = "@scala_proto_rules_grpc_core//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.18.0",
        sha1 = "5e4dbf944814d49499e3cbd9846ef58f629b5f32",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_stub",
        actual = "@scala_proto_rules_grpc_stub//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.18.0",
        sha1 = "74d794cf9b90b620e0ad698008abc4f55c1ca5e2",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_protobuf",
        actual = "@scala_proto_rules_grpc_protobuf//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.18.0",
        sha1 = "0d813fe080edb188953fea46803777e5ba6f41d4",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_netty",
        actual = "@scala_proto_rules_grpc_netty//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.18.0",
        sha1 = "c63e8b86af0fb16b5696480dc14f48e6eaa7193b",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/proto/grpc_context",
        actual = "@scala_proto_rules_grpc_context//jar",
    )

    native.maven_jar(
        name = "scala_proto_rules_guava",
        # io.grpc:grpc-core:1.18.0 defines a dependency on guava 25.1-android
        # see https://search.maven.org/artifact/io.grpc/grpc-core/1.18.0/jar
        artifact = "com.google.guava:guava:25.1-android",
        sha1 = "bdaab946ca5ad20253502d873ba0c3313d141036",
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

def _root_path(f):
    if f.is_source:
        return f.owner.workspace_root
    return "/".join([f.root.path, f.owner.workspace_root])

def _colon_paths(data):
    return ":".join([
        "{root},{path}".format(root = _root_path(f), path = f.path)
        for f in sorted(data)
    ])

def _retained_protos(inputs, blacklisted_proto_targets):
    blacklisted_protos = [dep for target in blacklisted_proto_targets for dep in target.proto.transitive_sources]
    blacklisted_protos_dict = dict(zip(blacklisted_protos, blacklisted_protos))
    return [f for f in inputs if blacklisted_protos_dict.get(f, None) == None]

def _valid_proto_paths(transitive_proto_path):
    """Build a list of valid paths to build the --proto_path arguments for the ScalaPB protobuf compiler
    In particular, the '.' path needs to be stripped out. This mirrors a fix in the java proto rules:
    https://github.com/bazelbuild/bazel/commit/af3605862047f7b553b7d2c19fa645714ea19bcf
    This is explained in this issue: https://github.com/bazelbuild/rules_scala/issues/687
    """
    return depset([path for path in transitive_proto_path if path != "."])

def _gen_proto_srcjar_impl(ctx):
    acc_imports = []
    transitive_proto_paths = []

    jvm_deps = []
    for target in ctx.attr.deps:
        if hasattr(target, "proto"):
            acc_imports.append(target.proto.transitive_sources)
            transitive_proto_paths.append(_valid_proto_paths(target.proto.transitive_proto_path))
        else:
            jvm_deps.append(target)

    acc_imports = depset(transitive = acc_imports)
    if "java_conversions" in ctx.attr.flags and len(jvm_deps) == 0:
        fail(
            "must have at least one jvm dependency if with_java is True (java_conversions is turned on)",
        )

    deps_jars = collect_jars(jvm_deps)

    worker_content = "{output}\n{paths}\n{flags_arg}\n{packages}\n{inputs}".format(
        output = ctx.outputs.srcjar.path,
        paths = _colon_paths(acc_imports.to_list()),
        # Command line args to worker cannot be empty so using padding
        flags_arg = "-" + ",".join(ctx.attr.flags),
        # Command line args to worker cannot be empty so using padding
        packages = "-" +
                   ":".join(depset(transitive = transitive_proto_paths).to_list()),
        # Pass inputs seprately because they doesn't always match to imports (ie blacklisted protos are excluded)
        inputs = ":".join(sorted([f.path for f in _retained_protos(acc_imports, ctx.attr.blacklisted_protos)]))
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
    "//external:io_bazel_rules_scala/dependency/proto/opencensus_api",
    "//external:io_bazel_rules_scala/dependency/proto/opencensus_contrib_grpc_metrics",
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
    scalac_jvm_flags: List of JVM flags to pass to the underlying scala_library attribute

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
        scalac_jvm_flags = [],
        java_conversions_deps = [],
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

    scala_proto_gen(
        name = srcjar,
        deps = deps,
        flags = flags,
        plugin = "@io_bazel_rules_scala//src/scala/scripts:scalapb_plugin",
        visibility = visibility,
    )

    external_deps = list(SCALAPB_DEPS + GRPC_DEPS if (
        with_grpc
    ) else SCALAPB_DEPS) + java_conversions_deps

    scala_library(
        name = name,
        srcs = [srcjar],
        deps = [srcjar] + external_deps,
        unused_dependency_checker_ignored_targets = [srcjar] + external_deps,
        exports = external_deps,
        scalac_jvm_flags = scalac_jvm_flags,
        visibility = visibility,
    )

def _strip_roots(roots, f):
    if f.is_source:
        for prefix in roots:
            if f.short_path.startswith(prefix + "/"):
                return f.short_path.replace(prefix + "/", "")
            return f.short_path
    else:
        for prefix in roots:
            if f.path.startswith(f.root.path + "/" + prefix + "/"):
                return f.path.replace(f.root.path + "/" + prefix + "/", "")
            return f.short_path

def _scala_proto_gen_impl(ctx):
    descriptors = [f for dep in ctx.attr.deps for f in dep.proto.transitive_descriptor_sets]
    roots = [f for dep in ctx.attr.deps for f in dep.proto.transitive_proto_path]
    sources = depset([_strip_roots(roots, f) for dep in ctx.attr.deps for f in _retained_protos(dep.proto.transitive_sources, ctx.attr.blacklisted_protos)]).to_list()

    srcdotjar = ctx.actions.declare_file("_" + ctx.label.name + "_src.jar")

    ctx.actions.run(
        inputs = [ctx.executable._protoc, ctx.executable.plugin] + descriptors,
        outputs = [srcdotjar],
        arguments = [
            "--plugin=protoc-gen-scala=" + ctx.executable.plugin.path,
            "--scala_out=%s:%s" % (",".join(ctx.attr.flags), srcdotjar.path),
            "--descriptor_set_in=" + ":".join([descriptor.path for descriptor in descriptors])]
            + sources,
        executable = ctx.executable._protoc,
        mnemonic = "ScalaProtoGen",
        use_default_shell_env = True,
    )

    ctx.actions.run_shell(
        command = "cp $1 $2",
        inputs = [srcdotjar],
        outputs = [ctx.outputs.srcjar],
        arguments = [srcdotjar.path, ctx.outputs.srcjar.path])

scala_proto_gen = rule(
    _scala_proto_gen_impl,
    attrs = {
        "deps": attr.label_list(mandatory = True, providers = [["proto"]]),
        "blacklisted_protos" : attr.label_list(providers = [["proto"]]),
        "flags": attr.string_list(default = []),
        "plugin": attr.label(executable = True, cfg = "host"),
        "_protoc": attr.label(executable = True, cfg = "host", default = "@com_google_protobuf//:protoc")
    },
    outputs = {
        "srcjar": "lib%{name}.srcjar",
    },
)
