load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "cats_core_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/org/typelevel/cats_core_2_12",
        ":cats_kernel_2_12",
        ":cats_macros_2_12",
        ":machinist_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "cats_kernel_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/org/typelevel/cats_kernel_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "cats_macros_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/org/typelevel/cats_macros_2_12",
        ":machinist_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "machinist_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//3rdparty/jvm/org/scala_lang:scala_reflect",
        "//external:jar/org/typelevel/machinist_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "macro_compat_2_12",
    exports = [
        "//3rdparty/jvm/org/scala_lang:scala_library",
        "//external:jar/org/typelevel/macro_compat_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)


