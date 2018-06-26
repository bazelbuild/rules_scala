load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "java_source_jar",
    # JavaSourceJar.srcjar was constructed with
    # `jar -cfM JavaSourceJar.srcjar JavaSource.java`
    srcs = ["JavaSourceJar.srcjar"],
    expect_java_output = False,
)
