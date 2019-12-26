load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "scala_library",
    exports = [
        "//external:jar/org/scala_lang/scala_library"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "scala_reflect",
    exports = [
        "//external:jar/org/scala_lang/scala_reflect",
        ":scala_library"
    ],
    visibility = [
        "//visibility:public"
    ]
)


