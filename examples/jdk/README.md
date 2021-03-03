Reproduce https://github.com/bazelbuild/rules_scala/issues/1233

Pass: bazel clean && bazel run --sandbox_debug --verbose_failures --toolchain_resolution_debug --javabase=:jdk8 --host_javabase=:jdk11 :MainJava
Fail: bazel clean && bazel run --sandbox_debug --verbose_failures --toolchain_resolution_debug --javabase=:jdk8 --host_javabase=:jdk11 :MainScala
