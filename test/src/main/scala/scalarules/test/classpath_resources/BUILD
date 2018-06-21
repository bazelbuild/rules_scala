load("//scala:scala.bzl", "scala_binary")

scala_binary(
    name = "classpath_resource",
    srcs = ["ObjectWithClasspathResources.scala"],
    classpath_resources = [
        "//test/src/main/resources/scalarules/test:byes",
        "//test/src/main/resources/scalarules/test:hellos",
        "//test/src/main/resources/scalarules/test:more-byes",
        "//test/src/main/resources/scalarules/test:more-hellos",
    ],
    main_class = "scalarules.test.classpathresources.ObjectWithClasspathResources",
    visibility = ["//visibility:public"],
)

scala_binary(
    name = "classpath_resource_duplicates",
    srcs = ["ObjectWithDuplicateClasspathResources.scala"],
    classpath_resources = [
        "//test/src/main/resources/scalarules/test/classpath_resource1:classpath-resource",
        "//test/src/main/resources/scalarules/test/classpath_resource2:classpath-resource",
    ],
    main_class = "scalarules.test.classpathresources.ObjectWithDuplicateClasspathResources",
)
