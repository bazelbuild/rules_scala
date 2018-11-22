"""Rules for organizing thrift files."""

load("@io_bazel_rules_scala//thrift:thrift_info.bzl", "ThriftInfo")

def empty_thrift_info():
    return ThriftInfo(srcs = depset(), transitive_srcs = depset())

def merge_thrift_infos(tis):
    return ThriftInfo(
        srcs = depset(transitive = [t.srcs for t in tis]),
        transitive_srcs = depset(transitive = [t.transitive_srcs for t in tis]),
    )

def _common_prefix(strings):
    pref = None
    for s in strings:
        if pref == None:
            pref = s
        elif s.startswith(pref):
            pass
        else:
            tmp_pref = pref
            for end in range(0, len(pref) + 1):
                test = pref[0:end]
                if s.startswith(test):
                    tmp_pref = test
            pref = tmp_pref
    return pref

def _thrift_library_impl(ctx):
    prefixes = [
        p
        for p in ctx.attr.absolute_prefixes + [ctx.attr.absolute_prefix]
        if p != ""
    ]

    src_paths = [f.path for f in ctx.files.srcs]

    zipper_args = "\n".join(src_paths) + "\n"
    if len(prefixes) > 0:
        common_prefix = _common_prefix(src_paths)
        found_prefixes = [p for p in prefixes if common_prefix.find(p) >= 0]

        if len(found_prefixes) == 0:
            fail(
                "could not find prefix from available prefixes: {prefixes} in the common prefix: {common_prefix}"
                    .format(prefixes = ",".join(prefixes), common_prefix = common_prefix),
            )
        elif len(found_prefixes) > 1:
            fail(
                "Too many not prefixes found, matched: {found_prefixes} in the common prefix: {common_prefix}"
                    .format(
                    found_prefixes = ",".join(found_prefixes),
                    common_prefix = common_prefix,
                ),
            )
        else:
            prefix = found_prefixes[0]
            pos = common_prefix.find(prefix)
            endpos = pos + len(prefix)
            actual_prefix = common_prefix[0:endpos]
            zipper_args = "\n".join(
                ["%s=%s" % (src[endpos + 1:], src) for src in src_paths],
            ) + "\n"

    # external jars are references to things srcs may depend on
    # ARE built as part of this target, but are not combined
    # into the output jar. They are included in the ThriftInfo provider
    externals = []
    for f in ctx.attr.external_jars:
        externals.extend(f.files.to_list())

    if len(src_paths) > 0:
        zipper_arg_path = ctx.actions.declare_file(
            "%s_zipper_args" % ctx.outputs.libarchive.path,
        )
        ctx.actions.write(zipper_arg_path, zipper_args)

        # We move the files and touch them so that the output file is a purely deterministic
        # product of the _content_ of the inputs
        cmd = """
rm -f {out}
{zipper} c {out} @{path}
"""

        cmd = cmd.format(
            out = ctx.outputs.libarchive.path,
            path = zipper_arg_path.path,
            zipper = ctx.executable._zipper.path,
        )
        ctx.actions.run_shell(
            inputs = ctx.files.srcs + [ctx.executable._zipper, zipper_arg_path],
            outputs = [ctx.outputs.libarchive],
            command = cmd,
            progress_message = "making thrift archive %s (%s files)" %
                               (ctx.label, len(src_paths)),
        )
        srcs_depset = depset([ctx.outputs.libarchive] + externals)
    else:
        # we still have to create the output we declared
        ctx.actions.run_shell(
            inputs = [ctx.executable._zipper],
            outputs = [ctx.outputs.libarchive],
            command = """
echo "empty" > {out}.contents
rm -f {out}
{zipper} c {out} {out}.contents
rm {out}.contents
""".format(
                out = ctx.outputs.libarchive.path,
                zipper = ctx.executable._zipper.path,
            ),
            progress_message = "making empty thrift archive %s" % ctx.label,
        )
        srcs_depset = depset(externals)

    transitive_srcs = depset(
        transitive = _collect_thrift_srcs(ctx.attr.deps, srcs_depset),
    )

    return [ThriftInfo(
        srcs = srcs_depset,
        transitive_srcs = transitive_srcs,
    )]

def _collect_thrift_srcs(targets, init):
    ds = [init]
    for target in targets:
        ds.append(target[ThriftInfo].transitive_srcs)
    return ds

# Some notes on the raison d'etre of thrift_library vs. code gen specific
# targets. The idea is to be able to separate concerns -- thrift_library is
# concerned purely with the ownership and organization of thrift files. It
# is not concerned with what to do with them. Thus, the code gen specific
# targets  will take the graph of thrift_libraries and use them to generate
# code. This organization is useful because it means that if there are
# different code generation targets, we don't need to have a whole separate
# tree of targets organizing the thrifts per code gen paradigm.
thrift_library = rule(
    implementation = _thrift_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".thrift"]),
        "deps": attr.label_list(providers = [ThriftInfo]),
        #TODO this is not necessarily the best way to do this... the goal
        # is that we want thrifts to be able to be imported via an absolute
        # path. But the thrift files have no clue what part of their path
        # should serve as the base for the import... for example, if a file is
        # in src/main/thrift/com/hello/World.thrift, if something depends on that
        # via "include 'com/hello/World.thrift'", there is no way to know what
        # path that should be relative to. One option is to just search for anything
        # that matches that, but that could create correctness issues if there are more
        # than one in different parts of the tree. Another option is to take an argument
        # that references namespace, and base the tree off of that. The downside
        # to that is that thrift_library then gets enmeshed in the details of code
        # generation. This could also be something punted to scrooge_scala_library
        # or whatever, but I think that we should make it such that the archive
        # created by this is created in such a way that absolute imports work...
        "absolute_prefix": attr.string(default = "", mandatory = False),
        "absolute_prefixes": attr.string_list(),
        # This is a list of JARs which only Thrift files
        # these files WILL be compiled as part of the current target
        "external_jars": attr.label_list(allow_files = [".jar"]),
        "_zipper": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@bazel_tools//tools/zip:zipper"),
            allow_files = True,
        ),
    },
    outputs = {"libarchive": "lib%{name}.jar"},
    provides = [ThriftInfo],
)
