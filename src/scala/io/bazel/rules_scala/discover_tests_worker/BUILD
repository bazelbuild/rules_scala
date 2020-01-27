load("//scala:defs.bzl", "scala_binary")

scala_binary(
	name = "discover_tests_worker",
	srcs = ["DiscoverTestsWorker.scala"],
        main_class = "io.bazelr.rules_scala.discover_tests_worker.DiscoverTestsWorker",
	deps = [
	     "@io_bazel_rules_scala_classgraph//jar:jar",
	     "@io_bazel_rules_scala//src/java/io/bazel/rules_scala/worker",
	],
        visibility = ["//visibility:public"],
)
