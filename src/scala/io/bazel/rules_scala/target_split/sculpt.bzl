load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
    "collect_plugin_paths",
)

def make_sculpt():
    new_git_repository(
        name = "sculpt",
        remote = "https://github.com/johnynek/scala-sculpt.git",
        commit = "d7fa6084f47034caea115bce9a38ff5e68fbfb08",
        build_file_content = """
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "sculpt",
    srcs = glob(["src/main/scala/**/*.scala"]),
    resources = ["src/main/resources/scalac-plugin.xml"],
    deps = [
      "@io_bazel_rules_scala_scala_reflect",
      "@io_bazel_rules_scala_scala_compiler",
      "@io_bazel_rules_scala_spray_json",
    ],
    visibility = ["//visibility:public"],
)
""",
    )

def run_sculpt(actions, outjson_file, sculpt, scalac, scalacopts, plugins, resources, deps, src_files):
    dep_files = collect_jars(deps).transitive_compile_jars.to_list()
    plugin_jars = collect_plugin_paths(plugins).to_list()

    args = actions.args()
    args.add("-Xplugin:" + sculpt[0].path)
    args.add("-Xplugin-require:sculpt")
    args.add("-P:sculpt:out=" + outjson_file.path)

    for pjar in plugin_jars:
        args.add("-Xplugin:" + pjar.path)

    args.add_all(scalacopts)
    args.add("-usejavacp")
    args.add_joined("-toolcp", dep_files, join_with = ":")
    args.add_joined("-classpath", dep_files, join_with = ":")
    args.add_all([f.path for f in src_files])

    actions.run(
        outputs = [outjson_file],
        inputs = src_files + dep_files + plugin_jars + sculpt + resources,
        arguments = [args],
        executable = scalac,
    )

def sculpt_json_impl(ctx):
    outjson = ctx.actions.declare_file(ctx.label.name + "_sculpt.json")
    run_sculpt(
        ctx.actions,
        outjson,
        ctx.files._sculpt_plugin,
        ctx.executable._scalac_runner,
        ctx.attr.scalacopts,
        ctx.attr.plugins,
        ctx.files.resources,
        ctx.attr.deps,
        ctx.files.srcs,
    )
    return [DefaultInfo(files = depset([outjson]))]

sculpt_json = rule(
    implementation = sculpt_json_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [
            ".scala",
        ]),
        "deps": attr.label_list(
            providers = [[JavaInfo]],
        ),
        "resources": attr.label_list(),
        "scalacopts": attr.string_list(),
        "plugins": attr.label_list(),
        "_scalac_runner": attr.label(
            default = Label("@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/target_split:scalac_runner"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
        "_sculpt_plugin": attr.label(
            default = Label("@sculpt//:sculpt.jar"),
            allow_files = True,
        ),
    },
)

# return the path of the json file
def sculpt_json_for(target, ctx):
    outname = target.label.name + "_sculpt.json"
    outjson = ctx.actions.declare_file(outname)
    run_sculpt(
        ctx.actions,
        outjson,
        ctx.files._sculpt_plugin,
        ctx.executable._scalac_runner,
        ctx.rule.attr.scalacopts,
        ctx.rule.attr.plugins,
        ctx.rule.files.resources,
        ctx.rule.attr.deps,
        ctx.rule.files.srcs,
    )

    return outjson

def run_processor(actions, sculpt_proc, target_short_name, json_file, pack_root_path, deps, exports, out_file):
    args = actions.args()
    args.add("--target_name")
    args.add(target_short_name)
    args.add("--sculpt_json")
    args.add(json_file.path)
    args.add("--package_root")
    args.add(pack_root_path)
    args.add("--deps")
    args.add_all(deps)
    args.add("--exports")
    args.add_all(exports)
    args.add("--output")
    args.add(out_file.path)

    actions.run(
        outputs = [out_file],
        inputs = [json_file],
        arguments = [args],
        executable = sculpt_proc,
    )

def split_build_for(target, ctx, json_file):
    outname = target.label.name + "_split.BUILD"
    outbuild = ctx.actions.declare_file(outname)
    run_processor(
        ctx.actions,
        ctx.executable._sculpt_processor,
        target.label.name,
        json_file,
        target.label.package,
        [str(d.label) for d in ctx.rule.attr.deps],
        [str(e.label) for e in ctx.rule.attr.exports],
        outbuild,
    )

    return outbuild

def sculpt_aspect_impl(target, ctx):
    json_file = sculpt_json_for(target, ctx)
    build_file = split_build_for(target, ctx, json_file)

    return [
        DefaultInfo(files = depset([json_file, build_file])),
        OutputGroupInfo(build_files = depset([build_file])),
    ]

sculpt_aspect = aspect(
    implementation = sculpt_aspect_impl,
    attr_aspects = [],
    attrs = {
        "_sculpt_processor": attr.label(
            default = Label("@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/target_split:sculpt_processor_runner"),
            executable = True,
            cfg = "host",
        ),
        "_scalac_runner": attr.label(
            default = Label("@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/target_split:scalac_runner"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
        "_sculpt_plugin": attr.label(
            default = Label("@sculpt//:sculpt.jar"),
            allow_files = True,
        ),
    },
)
