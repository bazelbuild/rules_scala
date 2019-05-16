load(
    "//scala/private:common.bzl",
    "write_manifest_file",
)
load("//scala/private:rule_impls.bzl", "compile_scala")
load("//scala_proto/private:dep_sets.bzl", "SCALAPB_DEPS", "GRPC_DEPS")


def _root_path(f):
    if f.is_source:
        return f.owner.workspace_root
    return "/".join([f.root.path, f.owner.workspace_root])


def _colon_paths(data):
    return ":".join([
        f.path
        for f in sorted(data)
    ])


def encode_named_generators(named_generators):
    return ",".join([k + "=" + v for (k, v) in sorted(named_generators.items())])


def proto_to_scala_src(ctx, label, code_generator, compile_proto, include_proto, transitive_proto_paths, flags, jar_output, named_generators, extra_generator_jars):
    worker_content = "{output}\n{included_proto}\n{flags_arg}\n{transitive_proto_paths}\n{inputs}\n{protoc}\n{extra_generator_pairs}\n{extra_cp_entries}".format(
        output = jar_output.path,
        included_proto = "-" + ":".join(sorted(["%s,%s" % (f.root.path, f.path) for f in include_proto])),
        # Command line args to worker cannot be empty so using padding
        flags_arg = "-" + ",".join(flags),
        transitive_proto_paths = "-" + ":".join(sorted(transitive_proto_paths)),
        # Command line args to worker cannot be empty so using padding
        # Pass inputs seprately because they doesn't always match to imports (ie blacklisted protos are excluded)
        inputs = _colon_paths(compile_proto),
        protoc = ctx.executable._protoc.path,
        extra_generator_pairs= "-" + encode_named_generators(named_generators),
        extra_cp_entries = "-" + _colon_paths(extra_generator_jars)
    )
    argfile = ctx.actions.declare_file(
        "%s_worker_input" % label.name,
        sibling = jar_output,
    )
    ctx.actions.write(output = argfile, content = worker_content)
    ctx.actions.run(
        executable = code_generator.files_to_run,
        inputs = compile_proto + include_proto + [argfile, ctx.executable._protoc] + extra_generator_jars,
        outputs = [jar_output],
        mnemonic = "ProtoScalaPBRule",
        progress_message = "creating scalapb files %s" % ctx.label,
        execution_requirements = {"supports-workers": "1"},
        arguments = ["@" + argfile.path],
    )


