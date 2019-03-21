load("//scala:scala.bzl", "scala_binary", "scala_test")
load(":helper.bzl", "create_dependencies", "get_dependency_labels")

scala_binary(
    name = "largeClasspath",
    srcs = ["ObjectWithLargeClasspath.scala"],
    main_class = "scalarules.test.large_classpath.ObjectWithLargeClasspath",
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = get_dependency_labels(
        amount = 250,
        length = 20,
    ),
)

create_dependencies(
    amount = 250,
    length = 20,
)
