load("//scala:scala.bzl", "scala_binary")

scala_binary(
    name = "classpath_resource",
    srcs = ["ObjectWithClasspathResources.scala"],
    main_class = "scala.test.classpathresources.ObjectWithClasspathResources",
    classpath_resources = [
        "//test/src/main/resources/scala/test:byes",
        "//test/src/main/resources/scala/test:hellos",
        "//test/src/main/resources/scala/test:more-byes",
        "//test/src/main/resources/scala/test:more-hellos"
    ],
)

