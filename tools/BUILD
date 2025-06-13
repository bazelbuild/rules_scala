load(
    "@com_github_bazelbuild_buildtools//buildifier:def.bzl",
    "buildifier",
    "buildifier_test",
)

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
    "-unused-variable",
]

buildifier_test(
    name = "lint_check",
    exclude_patterns = [
        "./.ijwb/*",
    ],
    lint_mode = "warn",
    lint_warnings = WARNINGS_CONFIG,
    mode = "check",
    no_sandbox = True,
    workspace = "//:MODULE.bazel",
)

buildifier(
    name = "lint_fix",
    exclude_patterns = [
        "./.ijwb/*",
    ],
    lint_mode = "fix",
    lint_warnings = WARNINGS_CONFIG,
    mode = "fix",
)
