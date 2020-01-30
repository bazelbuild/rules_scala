BootstrapInfo = provider(
    doc = "BootstrapProvider",
    fields = [
        "classpath",
        "macro_classpath",
        "repl_classpath",
    ],
)

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        # scalacopts = ctx.attr.scalacopts,
        # scalac_provider_attr = ctx.attr.scalac_provider_attr,
        # unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode,
        # plus_one_deps_mode = ctx.attr.plus_one_deps_mode,
        # enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        # scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        # scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    return [toolchain]

bootstrap_toolchain = rule(
    __impl,
        attrs = {
        # "scalacopts": attr.string_list(),
        # "scalac_provider_attr": attr.label(
        #     default = "@io_bazel_rules_scala//scala:scalac_default",
        #     providers = [_ScalacProvider],
        # ),
        # "unused_dependency_checker_mode": attr.string(
        #     default = "off",
        #     values = ["off", "warn", "error"],
        # ),
        # "plus_one_deps_mode": attr.string(
        #     default = "off",
        #     values = ["off", "on"],
        # ),
        # "enable_code_coverage_aspect": attr.string(
        #     default = "off",
        #     values = ["off", "on"],
        # ),
        # "scalac_jvm_flags": attr.string_list(),
    },
)
