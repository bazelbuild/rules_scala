load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
scala_import(
    name = "coursier",
    exports = [
        "//3rdparty/jvm/com/github/alexarchambault:argonaut_shapeless_6_2_2_12",
        "//3rdparty/jvm/org/scala_lang:scala_library",
        ":coursier_cache_2_12",
        ":coursier_core_2_12"
    ],
    jars = [
        "//external:jar/io/get_coursier/coursier_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "coursier_cache_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/io/get_coursier/coursier_cache_2_12",
        ":coursier_core_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "coursier_core_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang/modules:scala_xml_2_12",
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/io/get_coursier/coursier_core_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


