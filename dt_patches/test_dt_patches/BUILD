load("@rules_scala//scala:scala.bzl", "setup_scala_toolchain")
load(
    "@rules_scala//scala:scala_cross_version_select.bzl",
    "select_for_scala_version",
)

SCALA_LIBS = ["@scala_library"] + select_for_scala_version(
    any_2 = ["@scala_reflect"],
    any_3 = [
        "@scala3_interfaces",
        "@scala2_library",
        "@tasty_core",
        "@scala_asm",
    ],
    since_3_4 = ["@sbt_compiler_interface"],
)

setup_scala_toolchain(
    name = "dt_scala_toolchain",
    scala_compile_classpath = ["@scala_compiler"] + SCALA_LIBS,
    scala_library_classpath = SCALA_LIBS,
    scala_macro_classpath = SCALA_LIBS,
)
