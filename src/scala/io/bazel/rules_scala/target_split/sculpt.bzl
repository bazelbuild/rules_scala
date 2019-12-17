load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def make_sculpt():
  new_git_repository(
      name = "sculpt",
      remote = "https://github.com/johnynek/scala-sculpt.git",
      commit = "722c598fa38113f0641dc7806709682ca2534f6f",
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

def sculpt_json_impl(ctx):
    outjson = ctx.actions.declare_file(ctx.label.name + "_sculpt.json")
    args = ctx.actions.args()

    args.add("-Xplugin:" + ctx.files._sculpt_plugin[0].path)
    args.add("-Xplugin-require:sculpt")
    args.add("-P:sculpt:out=" + outjson.path)
    args.add("-usejavacp")
    args.add_joined("-toolcp", ctx.files.deps, join_with = ":")
    args.add_all([f.path for f in ctx.files.srcs])

    ctx.actions.run(
        outputs = [outjson],
        inputs = ctx.files.srcs + ctx.files._sculpt_plugin,
        arguments = [args],
        executable = ctx.executable._scalac_runner)

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
    }
)

