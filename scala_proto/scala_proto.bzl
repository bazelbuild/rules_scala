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
        artifact = "com.trueaccord.scalapb:compilerplugin_2.11:0.6.5",
        sha1 = "290094c632c95b36b6f66d7dbfdc15242b9a247f",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_plugin',
        actual = '@scala_proto_rules_scalapb_plugin//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_protoc_bridge",
        artifact = "com.trueaccord.scalapb:protoc-bridge_2.11:0.3.0-M1",
        sha1 = "73d38f045ea8f09cc1264991d1064add6eac9e00",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/protoc_bridge',
        actual = '@scala_proto_rules_protoc_bridge//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_slalapbc",
        artifact = "com.trueaccord.scalapb:scalapbc_2.11:0.6.5",
        sha1 = "b204d6d56a042b973af5b6fe28f81ece232d1fe4",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapbc',
        actual = '@scala_proto_rules_slalapbc//jar'
    )

    native.maven_jar(
        name = "scala_proto_rules_scalapb_runtime",
        artifact = "com.trueaccord.scalapb:scalapb-runtime_2.11:0.6.5",
        sha1 = "ac9287ff48c632df525773570ee4842e3ddf40e9",
        server = "scala_proto_deps_maven_server",
    )

    native.bind(
        name = 'io_bazel_rules_scala/dependency/proto/scalapb_runtime',
        actual = '@scala_proto_rules_scalapb_runtime//jar'
    )

def _colon_paths(data):
  return ':'.join([f.path for f in data])

def _gen_proto_srcjar_impl(ctx):
    acc_imports = depset()
    for target in ctx.attr.deps:
        acc_imports += target.proto.transitive_sources
    worker_content = "{output}\n{paths}".format(
        output = ctx.outputs.srcjar.path,
        paths = _colon_paths(acc_imports),
    )
    argfile = ctx.new_file(ctx.outputs.srcjar, "%s_worker_input" % ctx.label.name)
    ctx.file_action(output=argfile, content=worker_content)
    ctx.action(
        executable = ctx.executable._pluck_scalapb_scala,
        inputs = list(acc_imports) + [argfile],
        outputs = [ctx.outputs.srcjar],
        mnemonic="ProtoScalaRule",
        progress_message = "creating scalapb files %s" % ctx.label,
        execution_requirements={"supports-workers": "1"},
        arguments=["@" + argfile.path],
    )

proto_scala_srcjar = rule(
    _gen_proto_srcjar_impl,
    attrs={
        "deps": attr.label_list(
            mandatory=True,
            allow_rules=["proto_library"]
        ),
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
