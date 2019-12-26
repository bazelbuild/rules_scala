load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "org_eclipse_lsp4j_generator",
    exports = [
        "//3rdparty/jvm/org/eclipse/xtend:org_eclipse_xtend_lib",
        "//external:jar/org/eclipse/lsp4j/org_eclipse_lsp4j_generator",
        ":org_eclipse_lsp4j_jsonrpc"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "org_eclipse_lsp4j_jsonrpc",
    exports = [
        "//3rdparty/jvm/com/google/code/gson:gson",
        "//external:jar/org/eclipse/lsp4j/org_eclipse_lsp4j_jsonrpc"
    ],
    visibility = [
        "//visibility:public"
    ]
)


