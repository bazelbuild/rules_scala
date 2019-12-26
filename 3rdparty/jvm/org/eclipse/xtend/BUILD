load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
java_library(
    name = "org_eclipse_xtend_lib",
    exports = [
        "//3rdparty/jvm/org/eclipse/xtext:org_eclipse_xtext_xbase_lib",
        "//external:jar/org/eclipse/xtend/org_eclipse_xtend_lib",
        ":org_eclipse_xtend_lib_macro"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "org_eclipse_xtend_lib_macro",
    exports = [
        "//3rdparty/jvm/org/eclipse/xtext:org_eclipse_xtext_xbase_lib",
        "//external:jar/org/eclipse/xtend/org_eclipse_xtend_lib_macro"
    ],
    visibility = [
        "//visibility:public"
    ]
)


