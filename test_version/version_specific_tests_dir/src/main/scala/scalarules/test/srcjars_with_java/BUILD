load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "mixed_language_source_jar",
    # MixedLanguageSourceJar.srcjar was constructed with
    # `jar -cfM MixedLanguageSourceJar.srcjar JavaSource.java ScalaSource.scala`
    srcs = ["MixedLanguageSourceJar.srcjar"],
)

scala_library(
    name = "mixed_language_dependent",
    srcs = ["MixedLanguageDependent.scala"],
    deps = [":mixed_language_source_jar"],
)

scala_library(
    name = "java_source_jar",
    # JavaSourceJar.srcjar was constructed with
    # `jar -cfM JavaSourceJar.srcjar JavaSource.java`
    srcs = ["JavaSourceJar.srcjar"],
)

scala_library(
    name = "java_dependent",
    srcs = ["JavaDependent.scala"],
    deps = [":java_source_jar"],
)
