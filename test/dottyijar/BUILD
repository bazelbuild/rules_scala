load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "private-members",
    srcs = ["PrivateMembers.scala"],
    scala_version = "3.6.2",
    tags = ["manual"],
)

scala_binary(
    name = "private-members-dependent",
    srcs = ["PrivateMembersDependent.scala"],
    main_class = "dottyijar.Main",
    scala_version = "3.6.2",
    tags = ["manual"],
    deps = [":private-members"],
)

scala_library(
    name = "definition-values",
    srcs = ["DefinitionValues.scala"],
    scala_version = "3.6.2",
    tags = ["manual"],
)

scala_library(
    name = "definition-values-dependent",
    srcs = ["DefinitionValuesDependent.scala"],
    main_class = "dottyijar.Main",
    scala_version = "3.6.2",
    tags = ["manual"],
    deps = [":definition-values"],
)
