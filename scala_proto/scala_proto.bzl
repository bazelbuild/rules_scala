load("//scala:scala.bzl",
  "scala_mvn_artifact",
  "scala_library",
  "collect_jars",
  "create_java_provider")

def scala_proto_repositories():
    native.maven_server(
        name = "scala_proto_deps_maven_server",
        url = "http://central.maven.org/maven2/",
    )

    native.maven_jar(
        name = "scala_proto_rules_protoc_jar",
        artifact = "com.github.os72:protoc-jar:3.2.0",
        sha1 = "7c06b12068193bd2080caf45580b0a00d2a31638",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/protoc',
        actual = '@scala_proto_rules_protoc_jar//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_plugin",
        artifact = scala_mvn_artifact("com.trueaccord.scalapb:compilerplugin:0.6.5"),
        sha1 = "290094c632c95b36b6f66d7dbfdc15242b9a247f",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_plugin',
        actual = '@scala_proto_rules_scalapb_plugin//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_protoc_bridge",
        artifact = scala_mvn_artifact("com.trueaccord.scalapb:protoc-bridge:0.3.0-M1"),
        sha1 = "73d38f045ea8f09cc1264991d1064add6eac9e00",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/protoc_bridge',
        actual = '@scala_proto_rules_protoc_bridge//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapbc",
        artifact = scala_mvn_artifact("com.trueaccord.scalapb:scalapbc:0.6.5"),
        sha1 = "b204d6d56a042b973af5b6fe28f81ece232d1fe4",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapbc',
        actual = '@scala_proto_rules_scalapbc//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_runtime",
        artifact = scala_mvn_artifact("com.trueaccord.scalapb:scalapb-runtime:0.6.5"),
        sha1 = "ac9287ff48c632df525773570ee4842e3ddf40e9",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_runtime',
        actual = '@scala_proto_rules_scalapb_runtime//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_runtime_grpc",
        artifact = scala_mvn_artifact("com.trueaccord.scalapb:scalapb-runtime-grpc:0.6.5"),
        sha1 = "9dc3374001f4190548db36a7dc87bd4f9bca6f9c",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_runtime_grpc',
        actual = '@scala_proto_rules_scalapb_runtime_grpc//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_lenses",
        artifact = scala_mvn_artifact("com.trueaccord.lenses:lenses:0.4.12"),
        sha1 = "c5fbf5b872ce99d9a16d3392ccc0d15a0e43d823",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_lenses',
        actual = '@scala_proto_rules_scalapb_lenses//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_fastparse",
        artifact = scala_mvn_artifact("com.lihaoyi:fastparse:0.4.4"),
        sha1 = "f065fe0afe6fd2b4557d985c37362c36f08f9947",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_fastparse',
        actual = '@scala_proto_rules_scalapb_fastparse//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_core",
        artifact = "io.grpc:grpc-core:1.3.1",
        sha1 = "a9b38b4a19af3ef208f4f6bf7871876d959c5eb1",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/grpc_core',
        actual = '@scala_proto_rules_grpc_core//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_stub",
        artifact = "io.grpc:grpc-stub:1.3.1",
        sha1 = "60bdfa9d8c664a9d87ae461106eff6eed8da6c54",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/grpc_stub',
        actual = '@scala_proto_rules_grpc_stub//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_protobuf",
        artifact = "io.grpc:grpc-protobuf:1.3.1",
        sha1 = "9562e977cacd6e128a31686c3e6948d61873c496",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/grpc_protobuf',
        actual = '@scala_proto_rules_grpc_protobuf//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_netty",
        artifact = "io.grpc:grpc-netty:1.3.1",
        sha1 = "cc3831fccb76cfe21445f75cc055b5ffd979dc54",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/grpc_netty',
        actual = '@scala_proto_rules_grpc_netty//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_grpc_context",
        artifact = "io.grpc:grpc-context:1.3.1",
        sha1 = "28accd419b18d59055b8999f78f5cb7767c7bde8",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/grpc_context',
        actual = '@scala_proto_rules_grpc_context//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_guava",
        artifact = "com.google.guava:guava:19.0",
        sha1 = "6ce200f6b23222af3d8abb6b6459e6c44f4bb0e9",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/guava',
        actual = '@scala_proto_rules_guava//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_google_instrumentation",
        artifact = "com.google.instrumentation:instrumentation-api:0.3.0",
        sha1 = "a2e145e7a7567c6372738f5c5a6f3ba6407ac354",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/google_instrumentation',
        actual = '@scala_proto_rules_google_instrumentation//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec",
        artifact = "io.netty:netty-codec:4.1.8.Final",
        sha1 = "1bd0a2d032e5c7fc3f42c1b483d0f4c57eb516a3",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_codec',
        actual = '@scala_proto_rules_netty_codec//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http",
        artifact = "io.netty:netty-codec-http:4.1.8.Final",
        sha1 = "1e88617c4a6c88da7e86fdbbd9494d22a250c879",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_codec_http',
        actual = '@scala_proto_rules_netty_codec_http//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_socks",
        artifact = "io.netty:netty-codec-socks:4.1.8.Final",
        sha1 = "7f7c5f5b154646d7c571f8ca944fb813f71b1d51",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_codec_socks',
        actual = '@scala_proto_rules_netty_codec_socks//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_codec_http2",
        artifact = "io.netty:netty-codec-http2:4.1.8.Final",
        sha1 = "105a99ee5767463370ccc3d2e16800bd99f5648e",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_codec_http2',
        actual = '@scala_proto_rules_netty_codec_http2//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler",
        artifact = "io.netty:netty-handler:4.1.8.Final",
        sha1 = "db01139bfb11afd009a695eef55b43bbf22c4ef5",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_handler',
        actual = '@scala_proto_rules_netty_handler//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_buffer",
        artifact = "io.netty:netty-buffer:4.1.8.Final",
        sha1 = "43292c2622e340a0d07178c341ca3bdf3d662034",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_buffer',
        actual = '@scala_proto_rules_netty_buffer//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_transport",
        artifact = "io.netty:netty-transport:4.1.8.Final",
        sha1 = "905b5dadce881c9824b3039c0df36dabbb7b6a07",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_transport',
        actual = '@scala_proto_rules_netty_transport//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_resolver",
        artifact = "io.netty:netty-resolver:4.1.8.Final",
        sha1 = "2e116cdd5edc01b2305072b1dbbd17c0595dbfef",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_resolver',
        actual = '@scala_proto_rules_netty_resolver//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_common",
        artifact = "io.netty:netty-common:4.1.8.Final",
        sha1 = "ee62c80318413d2375d145e51e48d7d35c901324",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_common',
        actual = '@scala_proto_rules_netty_common//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_netty_handler_proxy",
        artifact = "io.netty:netty-handler-proxy:4.1.8.Final",
        sha1 = "c4d22e8b9071a0ea8d75766d869496c32648a758",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/netty_handler_proxy',
        actual = '@scala_proto_rules_netty_handler_proxy//jar'
    )

def _root_path(f):
    if f.is_source:
        return f.owner.workspace_root
    return '/'.join([f.root.path, f.owner.workspace_root])

def _colon_paths(data):
    return ':'.join(["{root},{path}".format(root=_root_path(f), path=f.path) for f in data])

def _gen_proto_srcjar_impl(ctx):
    acc_imports = depset()

    proto_deps, jvm_deps = [], []
    for target in ctx.attr.deps:
        if hasattr(target, 'proto'):
            proto_deps.append(target)
            acc_imports += target.proto.transitive_sources
        else:
            jvm_deps.append(target)

    if ctx.attr.with_java and len(jvm_deps) == 0:
        fail("must have at leat one jvm dependency if with_java is True")

    deps_jars = collect_jars(jvm_deps)

    # Command line args to worker cannot be empty so using padding
    flags = ["-"]
    if ctx.attr.with_grpc:
        flags.append("grpc")
    if ctx.attr.with_java:
        flags.append("java_conversions")
    if ctx.attr.with_flat_package:
        flags.append("flat_package")
    if ctx.attr.with_single_line_to_string:
        flags.append("single_line_to_string")

    worker_content = "{output}\n{paths}\n{flags_arg}".format(
        output = ctx.outputs.srcjar.path,
        paths = _colon_paths(acc_imports),
        flags_arg = ",".join(flags),
    )
    argfile = ctx.new_file(ctx.outputs.srcjar, "%s_worker_input" % ctx.label.name)
    ctx.file_action(output=argfile, content=worker_content)
    ctx.action(
        executable = ctx.executable._pluck_scalapb_scala,
        inputs = list(acc_imports) + [argfile],
        outputs = [ctx.outputs.srcjar],
        mnemonic="ProtoScalaPBRule",
        progress_message = "creating scalapb files %s" % ctx.label,
        execution_requirements={"supports-workers": "1"},
        arguments=["@" + argfile.path],
    )
    srcjarsattr = struct(
        srcjar = ctx.outputs.srcjar,
    )
    scalaattr = struct(
      outputs = None,
      compile_jars =  deps_jars.compile_jars,
      transitive_runtime_jars = deps_jars.transitive_runtime_jars,
    )
    java_provider = create_java_provider(ctx, scalaattr, depset())
    return struct(
        scala = scalaattr,
        providers = [java_provider],
        srcjars=srcjarsattr,
        extra_information=[struct(
          srcjars=srcjarsattr,
        )],
    )

scalapb_proto_srcjar = rule(
    _gen_proto_srcjar_impl,
    attrs={
        "deps": attr.label_list(
            mandatory=True,
            allow_rules=["proto_library", "java_proto_library", "scala_library"]
        ),
        "with_grpc": attr.bool(default=False),
        "with_java": attr.bool(default=False),
        "with_flat_package": attr.bool(default=False),
        "with_single_line_to_string": attr.bool(default=False),
        "_pluck_scalapb_scala": attr.label(
          executable=True,
          cfg="host",
          default=Label("//src/scala/scripts:scalapb_generator"),
          allow_files=True
        ),
    },
    outputs={
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

    srcjar = name + '_srcjar'
    scalapb_proto_srcjar(
        name = srcjar,
        with_grpc = with_grpc,
        with_java = with_java,
        with_flat_package = with_flat_package,
        with_single_line_to_string = with_single_line_to_string,
        deps = deps,
        visibility = visibility,
    )

    external_deps = list(SCALAPB_DEPS + GRPC_DEPS if (with_grpc) else SCALAPB_DEPS)

    scala_library(
        name = name,
        deps = [srcjar] + external_deps,
        exports = external_deps,
        visibility = visibility,
    )
