load("//scala:scala.bzl", "scala_library")
load(":pack_sources_test.bzl", "pack_sources_test_suite")

#TODO the way it SHOULD work (but isn't currently) is that
# the source_jar target should make available a compiled jar,
# and use_source_jar should depend on that internally

scala_library(
    name = "source_jar",
    # SourceJar1.srcjar was created by:
    # jar -cfM test/src/main/scala/scalarules/test/srcjars/SourceJar1.srcjar \
    # test/src/main/scala/scalarules/test/srcjars/SourceJar1.scala
    srcs = ["SourceJar1.srcjar"],
)

scala_library(
    name = "source_jar_no_expect_java_output",
    srcs = ["SourceJar1.srcjar"],
    expect_java_output = False,
)

scala_library(
    name = "multi_source_jar",
    # SourceJar2.srcjar was created the same way as SourceJar1.srcjar, i.e. by:
    # jar -cfM test/src/main/scala/scalarules/test/srcjars/SourceJar2.srcjar \
    # test/src/main/scala/scalarules/test/srcjars/SourceJar2.scala
    srcs = [
        "SourceJar1.srcjar",
        "SourceJar2.srcjar",
    ],
)

scala_library(
    name = "mixed_source_jar",
    srcs = [
        "SourceJar1.srcjar",
        "SourceJar2.scala",
    ],
)

scala_library(
    name = "use_source_jar",
    srcs = ["SourceJar2.scala"],
    deps = [":source_jar"],
)

pack_sources_test_suite(name = "pack_sources_test")
