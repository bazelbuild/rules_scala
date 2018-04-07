load("//scala:scala.bzl", "scala_binary")

scala_binary(
    name = "classpath_resource",
    srcs = ["ObjectWithClasspathResources.scala"],
    main_class = "scala.test.classpathresources.ObjectWithClasspathResources",
    visibility = ["//visibility:public"],
    classpath_resources = [
        "//test/src/main/resources/scala/test:byes",
        "//test/src/main/resources/scala/test:hellos",
        "//test/src/main/resources/scala/test:more-byes",
        "//test/src/main/resources/scala/test:more-hellos"
    ],
)

scala_binary(
    name = "classpath_resource_duplicates",
    srcs = ["ObjectWithDuplicateClasspathResources.scala"],
    main_class = "scala.test.classpathresources.ObjectWithDuplicateClasspathResources",
    classpath_resources = [
        "//test/src/main/resources/scala/test/classpath_resource1:classpath-resource",
        "//test/src/main/resources/scala/test/classpath_resource2:classpath-resource",
    ],
)