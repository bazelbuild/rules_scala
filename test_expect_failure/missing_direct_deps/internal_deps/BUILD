package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test", "scala_binary")
load(":custom-jvm-rule.bzl", "custom_jvm")

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

scala_library(
    name="dependent_on_some_java_provider",
    srcs=[
        "HasCustomJavaProviderDependency.scala",
        ],
    deps = ["direct_java_provider_dependency"],    
)

custom_jvm(
    name="direct_java_provider_dependency",
    deps = ["transitive_dependency"],
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

java_library(
    name="java_library_dependent_on_some_java_provider",
    srcs=[
        "JavaLibraryHasCustomJavaProviderDependency.java",
        ],
    deps = ["direct_java_provider_dependency"],
)

java_library(
    name="java_library_dependent_on_java_library",
    srcs=[
        "JavaLibraryHasCustomJavaProviderDependency.java",
        ],
    deps = ["direct_java_library_dependency"],
)

java_library(
    name="direct_java_library_dependency",
    srcs = ["Placeholder.java"],
    deps = ["transitive_dependency"],
)
