load("//scala:scala.bzl", "scala_binary")
load(":helper.bzl", "create_dependencies", "get_dependency_labels")

scala_binary(
    main_class = "scala.test.large_classpath.ObjectWithLargeClasspath",
    name = "largeClasspath",
    srcs = ["ObjectWithLargeClasspath.scala"],
    deps = get_dependency_labels(amount = 250, length = 20),
)

create_dependencies(amount = 250, length = 20)
