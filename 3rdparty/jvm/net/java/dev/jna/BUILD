load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "jna",
    exports = [
        "//external:jar/net/java/dev/jna/jna"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "jna_platform",
    exports = [
        "//external:jar/net/java/dev/jna/jna_platform",
        ":jna"
    ],
    visibility = [
        "//visibility:public"
    ]
)


