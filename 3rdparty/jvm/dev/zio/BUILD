load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "izumi_reflect_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/dev/zio/izumi_reflect_2_12",
        ":izumi_reflect_thirdparty_boopickle_shaded_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "izumi_reflect_thirdparty_boopickle_shaded_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/dev/zio/izumi_reflect_thirdparty_boopickle_shaded_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



scala_import(
    name = "zio",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        ":izumi_reflect_2_12",
        ":zio_stacktracer_2_12"
    ],
    jars = [
        "//external:jar/dev/zio/zio_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "zio_stacktracer_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/dev/zio/zio_stacktracer_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


