def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
      scalacopts = ctx.attr.scalacopts,
      plugins = ctx.attr.plugins,
      scalac_jvm_flags = ctx.attr.plugins,
      singlejar = ctx.executable.singlejar,
      ijar = ctx.executable.ijar,
      zipper = ctx.executable.zipper,
      scalac = ctx.executable.scalac,
      default_classpath = ctx.attr.default_classpath,
      repl_runtime_deps = ctx.attr.repl_runtime_deps,
  )
  return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        'scalacopts': attr.string_list(),
        'plugins': attr.label_list(allow_files = ['.jar']),
        'scalac_jvm_flags': attr.string_list(),
        'singlejar': attr.label(
            executable = True,
            cfg = "host",
            default = Label("@bazel_tools//tools/jdk:singlejar"),
            allow_files = True),
        'ijar': attr.label(
            executable = True,
            cfg = "host",
            default = Label("@bazel_tools//tools/jdk:ijar"),
            allow_files = True),
        'zipper': attr.label(
            executable = True,
            cfg = "host",
            default = Label("@bazel_tools//tools/zip:zipper"),
            allow_files = True),
        'scalac': attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac"),
            allow_files = True),
        'default_classpath': attr.label_list(
            default = [
                Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_library"
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_reflect"
                ),
            ],
            providers = [JavaInfo]),
        'repl_runtime_deps': attr.label_list(
            default = [
                Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_compiler"
                ),
            ],
            providers = [JavaInfo]),
    })
