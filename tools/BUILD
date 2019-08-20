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