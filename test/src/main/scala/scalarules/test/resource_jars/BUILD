load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_test")

java_library(
    name = "jarWithResources",
    resources = [
            "//test/src/main/resources/scalarules/test:byes",
            "//test/src/main/resources/scalarules/test:hellos",
            "//test/src/main/resources/scalarules/test:more-byes",
            "//test/src/main/resources/scalarules/test:more-hellos",
    ],
    visibility = ["//visibility:public"],
)

scala_test(
    name = "resource_jars",
    srcs = ["TestResourceJars.scala"],
    resource_jars = [":jarWithResources"],
)
