load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")

[
    buildifier(
        name = "buildifier@%s" % mode,
        mode = mode,
    )
    for mode in [
        "check",
        "diff",
        "fix",
        "print_if_changed",
    ]
]

[
    buildifier(
        name = "buildifier@lint_%s" % lint_mode,
        lint_mode = lint_mode,
        lint_warnings = [
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
        ],
    )
    for lint_mode in [
        "warn",
        "fix",
    ]
]
