load("//src/java/io/bazel/rulesscala/scalac:scalac.bzl", "source_jar")

[
    source_jar(
        name = d,
        srcs = glob(["%s/*.java" % d]),
        outs = "%s.srcjar" % d,
        visibility = ["//visibility:public"],
    )
    for d in [
        "after_2_12_13_and_before_2_13_12",
        "after_2_13_12",
        "before_2_12_13",
    ]
]
