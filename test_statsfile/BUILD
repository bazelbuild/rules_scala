load(
    "//scala:scala.bzl",
    "scala_binary",
)

load("//test:check_statsfile.bzl", "check_statsfile", "check_statsfile_empty")

scala_binary(
    name = "Simple",
    srcs = ["Simple.scala"],
    main_class = "scalarules.test.Simple",
    print_compile_time = True,
    deps = [],
)

scala_binary(
    name = "SimpleNoStatsFile",
    srcs = ["Simple.scala"],
    main_class = "scalarules.test.Simple",
    print_compile_time = True,
    deps = [],
)

check_statsfile("Simple")

check_statsfile_empty("SimpleNoStatsFile")
