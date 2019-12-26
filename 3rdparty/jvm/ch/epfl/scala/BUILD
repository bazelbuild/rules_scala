load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
scala_import(
    name = "bloop_config",
    exports = [
        "//3rdparty/jvm/io/circe:circe_derivation_2_12",
        "//3rdparty/jvm/io/circe:circe_parser_2_12",
        "//3rdparty/jvm/org/scala_lang:scala_library"
    ],
    jars = [
        "//external:jar/ch/epfl/scala/bloop_config_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



scala_import(
    name = "bloop_launcher",
    exports = [
        "//3rdparty/jvm/net/java/dev/jna:jna",
        "//3rdparty/jvm/net/java/dev/jna:jna_platform",
        "//3rdparty/jvm/org/scala_lang:scala_library"
    ],
    jars = [
        "//external:jar/ch/epfl/scala/bloop_launcher_2_12"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "bsp4j",
    exports = [
        "//3rdparty/jvm/org/eclipse/lsp4j:org_eclipse_lsp4j_generator",
        "//3rdparty/jvm/org/eclipse/lsp4j:org_eclipse_lsp4j_jsonrpc",
        "//external:jar/ch/epfl/scala/bsp4j"
    ],
    visibility = [
        "//visibility:public"
    ]
)


