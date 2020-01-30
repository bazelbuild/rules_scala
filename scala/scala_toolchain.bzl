ScalaInfo = provider(
    doc = "ScalaInfo",
    fields = [
        "scalacopts",
        "unused_dependency_checker_mode",
        "plus_one_deps_mode",
        "enable_code_coverage_aspect",
        "scalac_jvm_flags",
        "scala_test_jvm_flags",
        "scalac",
    ],
)

def _scala_toolchain_impl(ctx):
    scalainfo = ScalaInfo(
        scalacopts = ctx.attr.scalacopts,
        unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode,
        plus_one_deps_mode = ctx.attr.plus_one_deps_mode,
        enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
        scalac = ctx.attr.scalac,
    )
    toolchain = platform_common.ToolchainInfo(
        scalainfo = scalainfo,
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
        "scalac": attr.label(mandatory = True, allow_files = True),
    },
)
