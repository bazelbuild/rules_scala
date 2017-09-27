package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test", "scala_binary")

scala_library(
    name="transitive_dependency_user",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],    
)

scala_library(
    name="transitive_dependency_java_user",
    srcs=[
        "User.java",
        ],
    deps = ["direct_dependency"],    
)

scala_library(
    name="direct_dependency",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
)

scala_library(
    name="transitive_dependency",
    srcs=[
        "C.scala",
        ],
)

scala_binary(
    name="direct_binary_dependency",
    main_class="B",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
)

scala_binary(
    name="user_binary",
    main_class="A",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
)

scala_binary(
    name="binary_user_of_binary",
    main_class="D",
    srcs=[
        "D.scala",
        ],
    deps = ["direct_binary_dependency"],
)