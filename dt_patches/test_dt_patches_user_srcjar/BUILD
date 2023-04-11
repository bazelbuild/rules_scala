load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "setup_scala_toolchain",
)

SCALA_LIBS = [
    "@scala_library",
    "@scala_reflect",
]

setup_scala_toolchain(
    name = "dt_scala_toolchain",
    scala_compile_classpath = ["@scala_compiler"] + SCALA_LIBS,
    scala_library_classpath = SCALA_LIBS,
    scala_macro_classpath = SCALA_LIBS,
)
