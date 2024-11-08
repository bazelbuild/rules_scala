load(":aspect.bzl", "aspect_testscript")
load(":javainfo_from_aspect_test.bzl", "javainfo_from_aspect_test")
load(
    "//scala:scala.bzl",
    "scala_junit_test",
    "scala_library",
    "scala_specs2_junit_test",
    "scala_test",
)
load("//scala:scala_import.bzl", "scala_import")

aspect_testscript(
    name = "aspect_testscript",
    testonly = True,
    targets = [
        ":scala_library",
        ":scala_test",
        ":scala_junit_test",
        ":scala_specs2_junit_test",
    ],
)

sh_test(
    name = "aspect_test",
    testonly = True,
    srcs = ["aspect_testscript"],
)

scala_library(name = "scala_library")

scala_test(name = "scala_test")

scala_junit_test(
    name = "scala_junit_test",
    srcs = ["FakeJunitTest.scala"],
    suffixes = ["Test"],
)

scala_specs2_junit_test(
    name = "scala_specs2_junit_test",
    srcs = ["FakeJunitTest.scala"],
    suffixes = ["Test"],
)

#####################################
#use ensure_javainfo_from_aspect_test() to make sure scala_xxx can be visited in an aspect that has required_aspects=[JavaInfo]

scala_import(
    name = "com_google_guava_guava_21_0",
    jars = ["@com_google_guava_guava_21_0_with_file//:guava-21.0.jar"],
)

scala_library(
    name = "A",
    srcs = ["A.scala"],
)

#This library depends on a scala_library and a scala_import
scala_library(
    name = "B",
    deps = [
        "A",
        "com_google_guava_guava_21_0",
    ],
)

javainfo_from_aspect_test(
    name = "javainfo_from_aspect_test",
    expected = [
        "A",
        "com_google_guava_guava_21_0",
    ],
    target = "B",
    target_under_test = "B",
)
