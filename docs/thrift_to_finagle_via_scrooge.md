# Building Finagle Services from Thrift via Scrooge

This section describes the necessary steps to translate thrift definitions to
Finagle services using Scrooge.

`my_library/BUILD`

```python
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")
load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")

scala_library(
    name = "my_library",
    resources = glob(["src/main/resources/**/*"]),
    srcs = glob(["src/main/scala/com/tally/**/*.scala"]),
    deps = [
        ":scrooge",
    ],
    visibility = ["//visibility:public"]
)

thrift_library(
    name = "thrift_files",
    srcs = glob(["src/main/thrift/**/*.thrift"]),
    visibility = ["//visibility:public"],
)

scrooge_scala_library(
    name = "scrooge",
    visibility = ["//visibility:public"],
    deps = [
        ":thrift_files"
    ],
)
```


If you come across compile issues because you're defining Finagle specific classes, like `exception`, you must add those jars to the classpath when Scrooge compiles the Thrift files. See [#845](https://github.com/bazelbuild/rules_scala/issues/845) for background.

**Note**: The example below uses [rules_jvm_external](https://github.com/bazelbuild/rules_jvm_external)


`WORKSPACE`

```python
load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    name = "scrooge",
    artifacts = [
        "com.twitter:finagle-core_2.12:18.6.0",
        "com.twitter:scrooge-core_2.12:18.6.0",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ]
)

bind(
    name = "io_bazel_rules_scala/dependency/thrift/scrooge_core",
    actual = "//:scrooge_jars"
)
```

`BUILD` - this can reside anywhere, just make sure to change the label in your `WORKSPACE` to accurately point to the target defined below.

```python
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
scala_library(
    name = "scrooge_jars",
    exports = [
        "@scrooge//:com_twitter_finagle_core_2_12", # Adds Finagle classes to the classpath.
        "@scrooge//:com_twitter_scrooge_core_2_12"
    ],
    visibility = ["//visibility:public"]
)
```



