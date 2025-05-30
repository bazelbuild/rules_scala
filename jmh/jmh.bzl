load("@rules_java//java/common:java_common.bzl", "java_common")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala/private:rules/scala_binary.bzl", "scala_binary")
load("//scala/private:rules/scala_library.bzl", "scala_library")

def _scala_generate_benchmark(ctx):
    # we use required providers to ensure JavaInfo exists
    info = ctx.attr.src[JavaInfo]

    # TODO, if we emit more than one jar, which scala_library does not,
    # this might fail. We could possibly extend the BenchmarkGenerator
    # to accept more than one jar to scan, and then allow multiple labels
    # in ctx.attr.src
    outs = info.outputs.jars
    if len(outs) != 1:
        print("expected exactly 1 output jar in: " + ctx.label)

    # just try to take the first one and see if that works
    class_jar = outs[0].class_jar
    classpath = info.transitive_runtime_jars
    ctx.actions.run(
        outputs = [ctx.outputs.src_jar, ctx.outputs.resource_jar],
        inputs = classpath,
        executable = ctx.executable._generator,
        arguments = [ctx.attr.generator_type] + [
            f.path
            for f in [class_jar, ctx.outputs.src_jar, ctx.outputs.resource_jar] +
                     classpath.to_list()
        ],
        progress_message = "Generating benchmark code for %s" % ctx.label,
    )

scala_generate_benchmark = rule(
    implementation = _scala_generate_benchmark,
    attrs = {
        "src": attr.label(mandatory = True, providers = [[JavaInfo]]),
        "generator_type": attr.string(
            default = "reflection",
            mandatory = False,
        ),
        "_generator": attr.label(
            executable = True,
            cfg = "exec",
            default = (
                "//src/scala/io/bazel/rules_scala/jmh_support:benchmark_generator"
            ),
        ),
        "runtime_jdk": attr.label(
            default = "@rules_java//toolchains:current_java_runtime",
            providers = [java_common.JavaRuntimeInfo],
        ),
    },
    outputs = {
        "src_jar": "%{name}.srcjar",
        "resource_jar": "%{name}_resources.jar",
    },
)

def scala_benchmark_jmh(**kw):
    name = kw["name"]
    deps = kw.get("deps", [])
    runtime_deps = kw.get("runtime_deps", [])
    srcs = kw["srcs"]
    data = kw.get("data", [])
    generator_type = kw.get("generator_type", "reflection")
    lib = "%s_generator" % name
    testonly = kw.get("testonly", False)
    scalacopts = kw.get("scalacopts", [])
    main_class = kw.get("main_class", "org.openjdk.jmh.Main")
    runtime_jdk = kw.get(
        "runtime_jdk",
        "@rules_java//toolchains:current_java_runtime",
    )

    scala_library(
        name = lib,
        srcs = srcs,
        deps = deps + [Label("//jmh:jmh_core")],
        runtime_deps = runtime_deps,
        scalacopts = scalacopts,
        resources = kw.get("resources", []),
        resource_jars = kw.get("resource_jars", []),
        visibility = ["//visibility:public"],
        testonly = testonly,
        unused_dependency_checker_mode = "off",
    )

    codegen = name + "_codegen"
    scala_generate_benchmark(
        name = codegen,
        src = lib,
        generator_type = generator_type,
        testonly = testonly,
        runtime_jdk = runtime_jdk,
    )
    compiled_lib = name + "_compiled_benchmark_lib"
    scala_library(
        name = compiled_lib,
        srcs = ["%s.srcjar" % codegen],
        deps = deps + [
            Label("//jmh:jmh_core"),
            lib,
        ],
        resource_jars = ["%s_resources.jar" % codegen],
        testonly = testonly,
        unused_dependency_checker_mode = "off",
    )
    scala_binary(
        name = name,
        deps = [
            Label("//jmh:jmh_classpath"),
            compiled_lib,
        ],
        data = data,
        main_class = main_class,
        testonly = testonly,
        unused_dependency_checker_mode = "off",
        runtime_jdk = runtime_jdk,
    )
