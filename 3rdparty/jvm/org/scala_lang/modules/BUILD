load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
scala_import(
    name = "scala_java8_compat",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library"
    ],
    jars = [
        "//external:jar/org/scala_lang/modules/scala_java8_compat_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "scala_xml_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/org/scala_lang/modules/scala_xml_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


