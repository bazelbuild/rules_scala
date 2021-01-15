load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")

java_binary(
    name = "hello-from-jni-java",
    srcs = [
        "Hello.java",
        "Main.java",
    ],
    jvm_flags = ["-Djava.library.path=example/cc"],
    main_class = "example.Main",
    runtime_deps = ["//example/cc:hello-jni"],
)

scala_binary(
    name = "hello-from-jni-scala",
    srcs = [
        "HelloScala.scala",
        "MainScala.scala",
    ],
    data = ["//example/cc:hello-jni"],
    jvm_flags = ["-Djava.library.path=example/cc"],
    main_class = "example.MainScala",
)

scala_test(
    name = "hello-from-jni-scala-test",
    srcs = [
        "HelloScala.scala",
        "TestScala.scala",
    ],
    data = ["//example/cc:hello-jni"],
    jvm_flags = ["-Djava.library.path=example/cc"],
)
