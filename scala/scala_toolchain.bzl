def _scala_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        scalacopts = ctx.attr.scalacopts,
        unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode,
        plus_one_deps_mode = ctx.attr.plus_one_deps_mode,
        enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "unused_dependency_checker_mode": attr.string(
            default = "off",
            values = ["off", "warn", "error"],
        ),
        "plus_one_deps_mode": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "enable_code_coverage_aspect": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
    },
)
