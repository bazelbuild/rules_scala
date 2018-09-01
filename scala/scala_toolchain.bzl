load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider")

def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
      scalacopts = ctx.attr.scalacopts,
      scalac_repositories = ctx.attr.scalac_repositories,
      unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode)
  return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        'scalacopts': attr.string_list(),
        'scalac_repositories': attr.label(
            default = "@io_bazel_rules_scala//scala:scala_repositories_default",
            providers = [_ScalacProvider]),
        'unused_dependency_checker_mode': attr.string(
            default = "off", values = ["off", "warn", "error"]),
    })
