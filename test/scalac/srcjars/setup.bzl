def single_scala_file_srcjar(content):
    native.genrule(
        name = "single_scala",
        testonly = True,
        cmd = "echo '%s' > $@" % content,
        outs = ["single.scala"],
        visibility = ["//test/scalac/srcjars:__pkg__"],
    )

    native.genrule(
        name = "single_srcjar",
        testonly = True,
        srcs = [":single_scala"],
        outs = ["single.srcjar"],
        cmd = "$(location @bazel_tools//tools/zip:zipper) cf $@ $<",
        tools = ["@bazel_tools//tools/zip:zipper"],
        visibility = ["//test/scalac/srcjars:__pkg__"],
    )
