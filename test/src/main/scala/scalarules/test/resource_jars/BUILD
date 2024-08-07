load("//scala:scala.bzl", "scala_library", "scala_test")
load("//scala:scala_import.bzl", "scala_import")

scala_library(
    name = "jar_with_resources",
    testonly = True,
    resources = [
        "//test/src/main/resources/scalarules/test:byes",
        "//test/src/main/resources/scalarules/test:hellos",
        "//test/src/main/resources/scalarules/test:more-byes",
        "//test/src/main/resources/scalarules/test:more-hellos",
    ],
)

scala_import(
    name = "imported_jar_with_resources",
    jars = [
        ":jar_with_resources.jar",
    ],
)

scala_test(
    name = "resource_jars",
    srcs = ["TestResourceJars.scala"],
    resource_jars = [":imported_jar_with_resources"],
)
