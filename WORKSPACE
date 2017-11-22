workspace(name = "io_bazel_rules_scala")


new_http_archive(
  name = "scala",
  strip_prefix = "scala-2.11.11",
  sha256 = "12037ca64c68468e717e950f47fc77d5ceae5e74e3bdca56f6d02fd5bfd6900b",
  url = "https://downloads.lightbend.com/scala/2.11.11/scala-2.11.11.tgz",
  build_file_content = """
# scala.BUILD
java_import(
    name = "scala-xml",
    jars = ["lib/scala-xml_2.11-1.0.5.jar"],
    visibility = ["//visibility:public"],
)
java_import(
    name = "scala-parser-combinators",
    jars = ["lib/scala-parser-combinators_2.11-1.0.4.jar"],
    visibility = ["//visibility:public"],
)
java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)
java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)
java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)
""",
)

# scalatest has macros, note http_jar is invoking ijar
http_jar(
  name = "scalatest",
  url = "https://mirror.bazel.build/oss.sonatype.org/content/groups/public/org/scalatest/scalatest_2.11/2.2.6/scalatest_2.11-2.2.6.jar",
  sha256 = "f198967436a5e7a69cfd182902adcfbcb9f2e41b349e1a5c8881a2407f615962",
)

maven_server(
  name = "scalac_deps_maven_server",
  url = "https://mirror.bazel.build/repo1.maven.org/maven2/",
)

maven_jar(
  name = "scalac_rules_protobuf_java",
  artifact = "com.google.protobuf:protobuf-java:3.1.0",
  sha1 = "e13484d9da178399d32d2d27ee21a77cfb4b7873",
  server = "scalac_deps_maven_server",
)

# Template for binary launcher
BAZEL_JAVA_LAUNCHER_VERSION = "0.4.5"
http_file(
  name = "java_stub_template",
  url = ("https://raw.githubusercontent.com/bazelbuild/bazel/" +
         BAZEL_JAVA_LAUNCHER_VERSION +
         "/src/main/java/com/google/devtools/build/lib/bazel/rules/java/" +
         "java_stub_template.txt"),
  sha256 = "f09d06d55cd25168427a323eb29d32beca0ded43bec80d76fc6acd8199a24489",
)

bind(name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java", actual = "@scalac_rules_protobuf_java//jar")

bind(name = "io_bazel_rules_scala/dependency/scala/parser_combinators", actual = "@scala//:scala-parser-combinators")

bind(name = "io_bazel_rules_scala/dependency/scala/scala_compiler", actual = "@scala//:scala-compiler")

bind(name = "io_bazel_rules_scala/dependency/scala/scala_library", actual = "@scala//:scala-library")

bind(name = "io_bazel_rules_scala/dependency/scala/scala_reflect", actual = "@scala//:scala-reflect")

bind(name = "io_bazel_rules_scala/dependency/scala/scala_xml", actual = "@scala//:scala-xml")

bind(name = "io_bazel_rules_scala/dependency/scalatest/scalatest", actual = "@scalatest//jar")
