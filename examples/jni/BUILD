load("@rules_java//java:defs.bzl", "java_binary")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_test")

java_binary(
    name = "hello-from-jni-java",
    srcs = [
        "Hello.java",
        "Main.java",
    ],
    jvm_flags = ["-Djava.library.path=examples/jni/cc"],
    main_class = "examples.jni.Main",
    runtime_deps = ["//examples/jni/cc:hello-jni"],
)

scala_binary(
    name = "hello-from-jni-scala",
    srcs = [
        "HelloScala.scala",
        "MainScala.scala",
    ],
    data = ["//examples/jni/cc:hello-jni"],
    jvm_flags = ["-Djava.library.path=examples/jni/cc"],
    main_class = "examples.jni.MainScala",
)

scala_test(
    name = "hello-from-jni-scala-test",
    srcs = [
        "HelloScala.scala",
        "TestScala.scala",
    ],
    data = ["//examples/jni/cc:hello-jni"],
    jvm_flags = ["-Djava.library.path=examples/jni/cc"],
)
