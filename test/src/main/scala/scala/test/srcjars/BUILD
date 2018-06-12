load("//scala:scala.bzl", "scala_library")

#TODO the way it SHOULD work (but isn't currently) is that
# the source_jar target should make available a compiled jar,
# and use_source_jar should depend on that internally

scala_library(
    name = "source_jar",
    # SourceJar1.jar was created by:
    # jar -cfM test/src/main/scala/scala/test/srcjars/SourceJar1.srcjar \
    # test/src/main/scala/scala/test/srcjars/SourceJar1.scala
    srcs = ["SourceJar1.srcjar"],
)

scala_library(
    name = "use_source_jar",
    srcs = ["SourceJar2.scala"],
    deps = [":source_jar"],
)
