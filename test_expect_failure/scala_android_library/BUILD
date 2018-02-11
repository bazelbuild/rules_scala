load("//scala:scala_android.bzl", "scala_android_library")

scala_android_library(
    name = "missing_manifest",
    srcs = glob(["ScalaAndroidMissingManifestTest.scala"]),
    # if you include resource_files, manifest is also required
    resource_files = glob(["res/**"]),
    visibility = ["//visibility:public"],
)
