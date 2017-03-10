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

jmh_benchmark_generator_tool = Label("//src/scala/io/bazel/rules_scala/jmh_support:benchmark_generator")
jdk_tool = Label("//tools/defaults:jdk")
jar_tool = Label("@local_jdk//:jar")
jar_creator_tool = Label("//src/java/io/bazel/rulesscala/jar:binary")

def _scala_construct_runtime_classpath(deps):
  scala_targets = [d.scala for d in deps if hasattr(d, "scala")]
  java_targets = [d.java for d in deps if hasattr(d, "java")]
  files = []
  for scala in scala_targets:
    files += list(scala.transitive_runtime_deps)
    files += list(scala.transitive_runtime_exports)
  for java in java_targets:
    files += list(java.transitive_runtime_deps)
  return files

def _scala_generate_benchmark(ctx):
  class_jar = ctx.attr.src.scala.outputs.class_jar
  classpath = _scala_construct_runtime_classpath([ctx.attr.src])
  ctx.action(
      outputs = [ctx.outputs.benchmark_list, ctx.outputs.compiler_hints, ctx.outputs.src_jar],
      inputs = [class_jar] + classpath,
      executable = list(ctx.attr._generator.files)[0],
      arguments = [f.path for f in [class_jar, ctx.outputs.src_jar] + classpath],
      progress_message = "Generating benchmark code for %s" % ctx.label,
  )
  return struct(
      files=set([ctx.outputs.src_jar])
  )

scala_generate_benchmark = rule(
    implementation = _scala_generate_benchmark,
    attrs = {
        "src": attr.label(allow_single_file=True, mandatory=True),
        "_generator": attr.label(executable=True, cfg="host", default=Label("//src/scala/io/bazel/rules_scala/jmh_support:benchmark_generator"))
    },
    outputs = {
        "src_jar": "%{name}.srcjar",
        "benchmark_list": "resources/META-INF/BenchmarkList",
        "compiler_hints": "resources/META-INF/CompilerHints",
    },
)

def scala_benchmark_jmh(**kw):
  name = kw["name"]
  deps = kw.get("deps", [])
  srcs = kw["srcs"]
  lib = "%s_generator" % name
  scalacopts = kw.get("scalacopts", [])
  main_class = kw.get("main_class", "org.openjdk.jmh.Main")

  scala_library(
      name = lib,
      srcs = srcs,
      deps = deps + [
          "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
      ],
      scalacopts = scalacopts,
      visibility = ["//visibility:public"],
  )

  codegen = name + "_codegen"
  src_jar = "%s_jmh.srcjar" % name
  benchmark_list = "resources/META-INF/BenchmarkList"
  compiler_hints = "resources/META-INF/CompilerHints"

  scala_generate_benchmark(name=codegen, src=lib)

  compiled_lib = name + "_compiled_benchmark_lib"
  scala_library(
      name = compiled_lib,
      srcs = ["%s.srcjar" % codegen],
      deps = deps + [
          "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
          lib,
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
     main_class = main_class,
  )
