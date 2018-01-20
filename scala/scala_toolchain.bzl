def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
    scalacopts = ctx.attr.scalacopts,
    worker = ctx.executable.worker,
    library = ctx.attr.library,
    compiler = ctx.attr.compiler,
    reflect = ctx.attr.reflect,
  )
  return [toolchain]

scala_toolchain = rule(
  _scala_toolchain_impl,
  attrs = {
    'scalacopts': attr.string_list(),
    'worker': attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/scalac"), allow_files=True),
    'library': attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"), allow_files=True),
    'compiler': attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_compiler"), allow_files=True),
    'reflect': attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_reflect"), allow_files=True),
  }
)
