load("//scala:scala.bzl", "scala_binary")
load("//scala:scala_import.bzl", "scala_import")
#load("//scala:scala_maven_import_external.bzl", "scala_maven_import_external")

scala_binary(
    name = "fetch_sources",
    srcs = [ "FetchSources.scala" ],
    main_class = "scalarules.test.src.main.scala.scalarules.test.fetch_sources.FetchSources",
    deps = [ ":guava" ]
)

scala_import(
    name = "guava",
    jars = ["@com_google_guava_guava_21_0//jar"],
)
