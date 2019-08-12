load("//scala:scala.bzl", "scala_binary", "scala_library")
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def jmh_repositories(maven_servers = ["http://central.maven.org/maven2"]):
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_core",
        artifact = "org.openjdk.jmh:jmh-core:1.20",
        artifact_sha256 = "1688db5110ea6413bf63662113ed38084106ab1149e020c58c5ac22b91b842ca",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/jmh/jmh_core",
        actual = "@io_bazel_rules_scala_org_openjdk_jmh_jmh_core//jar",
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm",
        artifact = "org.openjdk.jmh:jmh-generator-asm:1.20",
        artifact_sha256 = "2dd4798b0c9120326310cda3864cc2e0035b8476346713d54a28d1adab1414a5",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/jmh/jmh_generator_asm",
        actual = "@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm//jar",
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection",
        artifact = "org.openjdk.jmh:jmh-generator-reflection:1.20",
        artifact_sha256 = "57706f7c8278272594a9afc42753aaf9ba0ba05980bae0673b8195908d21204e",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/jmh/jmh_generator_reflection",
        actual =
            "@io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection//jar",
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_ows2_asm_asm",
        artifact = "org.ow2.asm:asm:6.1.1",
        artifact_sha256 = "dd3b546415dd4bade2ebe3b47c7828ab0623ee2336604068e2d81023f9f8d833",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/jmh/org_ows2_asm_asm",
        actual = "@io_bazel_rules_scala_org_ows2_asm_asm//jar",
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple",
        artifact = "net.sf.jopt-simple:jopt-simple:5.0.3",
        artifact_sha256 = "6f45c00908265947c39221035250024f2caec9a15c1c8cf553ebeecee289f342",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name =
            "io_bazel_rules_scala/dependency/jmh/net_sf_jopt_simple_jopt_simple",
        actual = "@io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple//jar",
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_apache_commons_commons_math3",
        artifact = "org.apache.commons:commons-math3:3.6.1",
        artifact_sha256 = "1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name =
            "io_bazel_rules_scala/dependency/jmh/org_apache_commons_commons_math3",
        actual = "@io_bazel_rules_scala_org_apache_commons_commons_math3//jar",
    )

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
    classpath = info.transitive_runtime_deps
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
            cfg = "host",
            default = Label(
                "//src/scala/io/bazel/rules_scala/jmh_support:benchmark_generator",
            ),
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
    srcs = kw["srcs"]
    data = kw.get("data", [])
    generator_type = kw.get("generator_type", "reflection")
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
        resources = kw.get("resources", []),
        resource_jars = kw.get("resource_jars", []),
        visibility = ["//visibility:public"],
        unused_dependency_checker_mode = "off",
    )

    codegen = name + "_codegen"
    scala_generate_benchmark(
        name = codegen,
        src = lib,
        generator_type = generator_type,
    )
    compiled_lib = name + "_compiled_benchmark_lib"
    scala_library(
        name = compiled_lib,
        srcs = ["%s.srcjar" % codegen],
        deps = deps + [
            "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
            lib,
        ],
        resource_jars = ["%s_resources.jar" % codegen],
        unused_dependency_checker_mode = "off",
    )
    scala_binary(
        name = name,
        deps = [
            "//external:io_bazel_rules_scala/dependency/jmh/net_sf_jopt_simple_jopt_simple",
            "//external:io_bazel_rules_scala/dependency/jmh/org_apache_commons_commons_math3",
            compiled_lib,
        ],
        data = data,
        main_class = main_class,
        unused_dependency_checker_mode = "off",
    )
