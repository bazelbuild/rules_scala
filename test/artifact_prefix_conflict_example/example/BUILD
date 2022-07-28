load("//scala:scala.bzl", "scala_binary")

scala_binary(
    name = "example",
    srcs = ["ArtifactPrefixConflictExample.scala"],
    main_class = "example.ArtifactPrefixConflictExample",
    visibility = ["//visibility:public"],
    deps = ["//test/artifact_prefix_conflict_example/example/example:example-lib"],
)
