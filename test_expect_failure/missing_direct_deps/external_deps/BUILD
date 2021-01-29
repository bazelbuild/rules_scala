load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "transitive_external_dependency_user",
    testonly = True,
    srcs = [
        "A.scala",
    ],
    deps = ["external_dependency_user"],
)

scala_library(
    name = "external_dependency_user",
    testonly = True,
    srcs = [
        "B.scala",
    ],
    deps = ["@com_google_guava_guava_21_0//jar"],
)

scala_library(
    name = "transitive_external_dependency_user_file_group",
    testonly = True,
    srcs = [
        "A.scala",
    ],
    deps = ["external_dependency_user_file_group"],
)

scala_library(
    name = "external_dependency_user_file_group",
    testonly = True,
    srcs = [
        "B.scala",
    ],
    deps = ["@com_google_guava_guava_21_0_with_file//jar"],
)
