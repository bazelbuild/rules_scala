load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")

WARNINGS_CONFIG = [
    "-module-docstring",
    "-function-docstring",
    "-function-docstring-header",
    "-function-docstring-return",
    "-function-docstring-args",
    "-positional-args",
    "-unnamed-macro",
    "-name-conventions",
    "-print",
    "-bzl-visibility",
    "-no-effect",
    "-provider-params",
]

buildifier(
    name = "lint_check",
    lint_mode = "warn",
    lint_warnings = WARNINGS_CONFIG,
    mode = "check",
)

buildifier(
    name = "lint_fix",
    lint_mode = "fix",
    lint_warnings = WARNINGS_CONFIG,
    mode = "fix",
)
