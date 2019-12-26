load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "circe_core_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//3rdparty/jvm/org/typelevel:cats_core_2_12",
        "//external:jar/io/circe/circe_core_2_12",
        ":circe_numbers_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "circe_derivation_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/io/circe/circe_derivation_2_12",
        ":circe_core_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "circe_jawn_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//3rdparty/jvm/org/spire_math:jawn_parser_2_12",
        "//external:jar/io/circe/circe_jawn_2_12",
        ":circe_core_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "circe_numbers_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/io/circe/circe_numbers_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "circe_parser_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/io/circe/circe_parser_2_12",
        ":circe_core_2_12",
        ":circe_jawn_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


