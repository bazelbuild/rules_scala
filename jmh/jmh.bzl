load("//scala:scala.bzl", "scala_binary", "scala_library")

def jmh_repositories():
  native.maven_jar(
      name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_core",
      artifact = "org.openjdk.jmh:jmh-core:1.17.4",
      sha1 = "126d989b196070a8b3653b5389e602a48fe6bb2f",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/jmh/jmh_core',
      actual = '@io_bazel_rules_scala_org_openjdk_jmh_jmh_core//jar',
  )
  native.maven_jar(
      name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm",
      artifact = "org.openjdk.jmh:jmh-generator-asm:1.17.4",
      sha1 = "c85c3d8cfa194872b260e89770d41e2084ce2cb6",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/jmh/jmh_generator_asm',
      actual = '@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm//jar',
  )
  native.maven_jar(
       name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection",
       artifact = "org.openjdk.jmh:jmh-generator-reflection:1.17.4",
       sha1 = "f75a7823c9fcf03feed6d74aa44ea61fc70a8439",
  )
  native.bind(
       name = 'io_bazel_rules_scala/dependency/jmh/jmh_generator_reflection',
       actual = '@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection//jar',
  )
  native.maven_jar(
      name = "io_bazel_rules_scala_org_ows2_asm_asm",
      artifact = "org.ow2.asm:asm:5.0.4",
      sha1 = "0da08b8cce7bbf903602a25a3a163ae252435795",
  )
  native.bind(
      name = "io_bazel_rules_scala/dependency/jmh/org_ows2_asm_asm",
      actual = '@io_bazel_rules_scala_org_ows2_asm_asm//jar',
  )
  native.maven_jar(
      name = "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple",
      artifact = "net.sf.jopt-simple:jopt-simple:5.0.3",
      sha1 = "cdd846cfc4e0f7eefafc02c0f5dce32b9303aa2a",
  )
  native.bind(
      name = "io_bazel_rules_scala/dependency/jmh/net_sf_jopt_simple_jopt_simple",
      actual = '@io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple//jar',
  )
  native.maven_jar(
      name = "io_bazel_rules_scala_org_apache_commons_commons_math3",
      artifact = "org.apache.commons:commons-math3:3.6.1",
      sha1 = "e4ba98f1d4b3c80ec46392f25e094a6a2e58fcbf",
  )
  native.bind(
      name = "io_bazel_rules_scala/dependency/jmh/org_apache_commons_commons_math3",
      actual = '@io_bazel_rules_scala_org_apache_commons_commons_math3//jar',
  )


def scala_benchmark_jmh(**kw):
  name = kw["name"]
  deps = kw.get("deps", [])
  srcs = kw["srcs"]
  lib = "%s_generator" % name
  scalacopts = kw.get("scalacopts", [])
  scala_library(
      name = lib,
      srcs = srcs,
      deps = deps + [
          "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
      ],
      scalacopts = scalacopts,
      visibility = ["//visibility:public"],
  )
  tool = "__jmh_benchmark_generator"
  scala_binary(
    name = tool,
    main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
    deps = [
      "//src/scala/io/bazel/rules_scala/jmh_support:benchmark_generator_lib"
    ],
  )

  codegen = name + "_codegen"
  src_jar = "%s_jmh.srcjar" % name
  benchmark_list = "resources/META-INF/BenchmarkList"
  compiler_hints = "resources/META-INF/CompilerHints"
  native.genrule(
      name = codegen,
      srcs = [lib],
      outs = [src_jar, benchmark_list, compiler_hints],
      tools = [tool, "@local_jdk//:jar"],
      cmd = """
pushd `dirname $(location {lib})`
jar -xf `basename $(location {lib})`
popd
./$(location {tool}) $(location {lib}) $(@D)
pushd $(@D)/sources
jar -cf ../{name}_jmh.srcjar ./**/*
popd
""".format(tool=tool, lib=lib, name=name),
  )

  compiled_lib = name + "_compiled_benchmark_lib"
  scala_library(
      name = compiled_lib,
      srcs = [src_jar],
      deps = deps + [
          "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
          lib,
          codegen,
      ],
      resources = [benchmark_list, compiler_hints],
  )
  scala_binary(
     name = name,
     deps = [
         "//external:io_bazel_rules_scala/dependency/jmh/net_sf_jopt_simple_jopt_simple",
         "//external:io_bazel_rules_scala/dependency/jmh/org_apache_commons_commons_math3",
         compiled_lib,
    ],
     main_class = "org.openjdk.jmh.Main"
  )
