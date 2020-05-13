load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
scala_import(
    name = "snailgun_core",
    exports = [
        "//3rdparty/jvm/net/java/dev/jna:jna",
        "//3rdparty/jvm/net/java/dev/jna:jna_platform",
        "//3rdparty/jvm/org/scala_lang:scala_library"
    ],
    jars = [
        "//external:jar/me/vican/jorge/snailgun_core_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


