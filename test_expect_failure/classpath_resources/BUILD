load("//scala:scala.bzl", "scala_binary")

scala_binary(
    name = "classpath_resource_duplicates",
    srcs = ["ObjectWithDuplicateClasspathResources.scala"],
    main_class = "scala.test.classpathresources.ObjectWithDuplicateClasspathResources",
    classpath_resources = [
        "//test_expect_failure/classpath_resources/classpath_resource1:classpath-resource",
        "//test_expect_failure/classpath_resources/classpath_resource2:classpath-resource",
    ],
)