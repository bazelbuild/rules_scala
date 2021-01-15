load("@rules_java//java:defs.bzl", "java_library")

package(default_visibility = ["//visibility:public"])

load("//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")
load(":custom-jvm-rule.bzl", "custom_jvm")

scala_library(
    name = "transitive_dependency_user",
    srcs = [
        "A.scala",
    ],
    deps = ["direct_dependency"],
)

scala_library(
    name = "transitive_dependency_java_user",
    srcs = [
        "User.java",
    ],
    deps = ["direct_dependency"],
)

scala_library(
    name = "direct_dependency",
    srcs = [
        "B.scala",
    ],
    deps = ["transitive_dependency"],
)

scala_library(
    name = "transitive_dependency",
    srcs = [
        "C.scala",
    ],
)

scala_library(
    name = "dependent_on_some_java_provider",
    srcs = [
        "HasCustomJavaProviderDependency.scala",
    ],
    deps = ["direct_java_provider_dependency"],
)

custom_jvm(
    name = "direct_java_provider_dependency",
    deps = ["transitive_dependency"],
)

scala_binary(
    name = "direct_binary_dependency",
    srcs = [
        "B.scala",
    ],
    main_class = "B",
    deps = ["transitive_dependency"],
)

scala_binary(
    name = "user_binary",
    srcs = [
        "A.scala",
    ],
    main_class = "A",
    deps = ["direct_dependency"],
)

scala_binary(
    name = "binary_user_of_binary",
    srcs = [
        "D.scala",
    ],
    main_class = "D",
    deps = ["direct_binary_dependency"],
)

java_library(
    name = "java_library_dependent_on_some_java_provider",
    srcs = [
        "JavaLibraryHasCustomJavaProviderDependency.java",
    ],
    deps = ["direct_java_provider_dependency"],
)

java_library(
    name = "java_library_dependent_on_java_library",
    srcs = [
        "JavaLibraryHasCustomJavaProviderDependency.java",
    ],
    deps = ["direct_java_library_dependency"],
)

java_library(
    name = "direct_java_library_dependency",
    srcs = ["Placeholder.java"],
    deps = ["transitive_dependency"],
)

genrule(
    name = "transitive_dependency_jar_without_manifest",
    srcs = ["transitive_dependency.jar"],
    outs = ["transitive_dependency_without_manifest.jar"],
    cmd = "zip -d $(location transitive_dependency.jar) META-INF/MANIFEST.MF --out $@",
)

custom_jvm(
    name = "unstamped_direct_java_provider_dependency",
    deps = [":transitive_dep_without_manifest"],
)

custom_jvm(
    name = "transitive_dep_without_manifest",
    jar = "transitive_dependency_without_manifest.jar",
)

scala_library(
    name = "unstamped_jar_dependent_on_some_java_provider",
    srcs = [
        "HasCustomJavaProviderDependency.scala",
    ],
    deps = ["unstamped_direct_java_provider_dependency"],
)
