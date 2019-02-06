load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    _scala_binary_impl = "scala_binary_impl",
    _scala_junit_test_impl = "scala_junit_test_impl",
    _scala_library_for_plugin_bootstrapping_impl = "scala_library_for_plugin_bootstrapping_impl",
    _scala_library_impl = "scala_library_impl",
    _scala_macro_library_impl = "scala_macro_library_impl",
    _scala_repl_impl = "scala_repl_impl",
    _scala_test_impl = "scala_test_impl",
)
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
    _default_scala_version_jar_shas = "default_scala_version_jar_shas",
    _extract_major_version = "extract_major_version",
    _new_scala_default_repository = "new_scala_default_repository",
)
load(
    "@io_bazel_rules_scala//specs2:specs2_junit.bzl",
    _specs2_junit_dependencies = "specs2_junit_dependencies",
)

_launcher_template = {
    "_java_stub_template": attr.label(
        default = Label("@java_stub_template//file"),
    ),
}

_implicit_deps = {
    "_singlejar": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/jdk:singlejar"),
        allow_files = True,
    ),
    "_zipper": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/zip:zipper"),
        allow_files = True,
    ),
    "_java_toolchain": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
    ),
    "_host_javabase": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        cfg = "host",
    ),
    "_java_runtime": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
    ),
    "_scalac": attr.label(
        default = Label(
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac",
        ),
    ),
}

# Single dep to allow IDEs to pickup all the implicit dependencies.
_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
        ],
        allow_files = False,
    ),
}

_test_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
            ),
        ],
        allow_files = False,
    ),
}

_junit_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label("//external:io_bazel_rules_scala/dependency/junit/junit"),
            Label(
                "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
            ),
        ],
        allow_files = False,
    ),
}

# Common attributes reused across multiple rules.
_common_attrs_for_plugin_bootstrapping = {
    "srcs": attr.label_list(allow_files = [".scala", ".srcjar", ".java"]),
    "deps": attr.label_list(),
    "plugins": attr.label_list(allow_files = [".jar"]),
    "runtime_deps": attr.label_list(providers = [[JavaInfo]]),
    "data": attr.label_list(allow_files = True),
    "resources": attr.label_list(allow_files = True),
    "resource_strip_prefix": attr.string(),
    "resource_jars": attr.label_list(allow_files = True),
    "scalacopts": attr.string_list(),
    "javacopts": attr.string_list(),
    "jvm_flags": attr.string_list(),
    "scalac_jvm_flags": attr.string_list(),
    "javac_jvm_flags": attr.string_list(),
    "expect_java_output": attr.bool(default = True, mandatory = False),
    "print_compile_time": attr.bool(default = False, mandatory = False),
}

_common_attrs = {}
_common_attrs.update(_common_attrs_for_plugin_bootstrapping)
_common_attrs.update({
    # using stricts scala deps is done by using command line flag called 'strict_java_deps'
    # switching mode to "on" means that ANY API change in a target's transitive dependencies will trigger a recompilation of that target,
    # on the other hand any internal change (i.e. on code that ijar omits) WON’T trigger recompilation by transitive dependencies
    "_dependency_analyzer_plugin": attr.label(
        default = Label(
            "@io_bazel_rules_scala//third_party/dependency_analyzer/src/main:dependency_analyzer",
        ),
        allow_files = [".jar"],
        mandatory = False,
    ),
    "unused_dependency_checker_mode": attr.string(
        values = ["warn", "error", "off", ""],
        mandatory = False,
    ),
    "_unused_dependency_checker_plugin": attr.label(
        default = Label(
            "@io_bazel_rules_scala//third_party/unused_dependency_checker/src/main:unused_dependency_checker",
        ),
        allow_files = [".jar"],
        mandatory = False,
    ),
    "unused_dependency_checker_ignored_targets": attr.label_list(default = []),
})

_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}

_common_outputs = {
    "jar": "%{name}.jar",
    "deploy_jar": "%{name}_deploy.jar",
    "manifest": "%{name}_MANIFEST.MF",
    "statsfile": "%{name}.statsfile",
}

_library_outputs = {}
_library_outputs.update(_common_outputs)

_scala_library_attrs = {}
_scala_library_attrs.update(_implicit_deps)
_scala_library_attrs.update(_common_attrs)
_scala_library_attrs.update(_library_attrs)
_scala_library_attrs.update(_resolve_deps)

scala_library = rule(
    implementation = _scala_library_impl,
    attrs = _scala_library_attrs,
    outputs = _library_outputs,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

# the scala compiler plugin used for dependency analysis is compiled using `scala_library`.
# in order to avoid cyclic dependencies `scala_library_for_plugin_bootstrapping` was created for this purpose,
# which does not contain plugin related attributes, and thus avoids the cyclic dependency issue
_scala_library_for_plugin_bootstrapping_attrs = {}
_scala_library_for_plugin_bootstrapping_attrs.update(_implicit_deps)
_scala_library_for_plugin_bootstrapping_attrs.update(_library_attrs)
_scala_library_for_plugin_bootstrapping_attrs.update(_resolve_deps)
_scala_library_for_plugin_bootstrapping_attrs.update(
    _common_attrs_for_plugin_bootstrapping,
)
scala_library_for_plugin_bootstrapping = rule(
    implementation = _scala_library_for_plugin_bootstrapping_impl,
    attrs = _scala_library_for_plugin_bootstrapping_attrs,
    outputs = _library_outputs,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}
_scala_macro_library_attrs.update(_implicit_deps)
_scala_macro_library_attrs.update(_common_attrs)
_scala_macro_library_attrs.update(_library_attrs)
_scala_macro_library_attrs.update(_resolve_deps)

# Set unused_dependency_checker_mode default to off for scala_macro_library
_scala_macro_library_attrs["unused_dependency_checker_mode"] = attr.string(
    default = "off",
    values = ["warn", "error", "off", ""],
    mandatory = False,
)

scala_macro_library = rule(
    implementation = _scala_macro_library_impl,
    attrs = _scala_macro_library_attrs,
    outputs = _common_outputs,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

_scala_binary_attrs = {
    "main_class": attr.string(mandatory = True),
    "classpath_resources": attr.label_list(allow_files = True),
}
_scala_binary_attrs.update(_launcher_template)
_scala_binary_attrs.update(_implicit_deps)
_scala_binary_attrs.update(_common_attrs)
_scala_binary_attrs.update(_resolve_deps)
scala_binary = rule(
    implementation = _scala_binary_impl,
    attrs = _scala_binary_attrs,
    outputs = _common_outputs,
    executable = True,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

_scala_test_attrs = {
    "main_class": attr.string(
        default = "io.bazel.rulesscala.scala_test.Runner",
    ),
    "suites": attr.string_list(),
    "colors": attr.bool(default = True),
    "full_stacktraces": attr.bool(default = True),
    "_scalatest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        ),
    ),
    "_scalatest_runner": attr.label(
        cfg = "host",
        default = Label("//src/java/io/bazel/rulesscala/scala_test:runner"),
    ),
    "_scalatest_reporter": attr.label(
        default = Label("//scala/support:test_reporter"),
    ),
}
_scala_test_attrs.update(_launcher_template)
_scala_test_attrs.update(_implicit_deps)
_scala_test_attrs.update(_common_attrs)
_scala_test_attrs.update(_test_resolve_deps)
scala_test = rule(
    implementation = _scala_test_impl,
    attrs = _scala_test_attrs,
    outputs = _common_outputs,
    executable = True,
    test = True,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

_scala_repl_attrs = {}
_scala_repl_attrs.update(_launcher_template)
_scala_repl_attrs.update(_implicit_deps)
_scala_repl_attrs.update(_common_attrs)
_scala_repl_attrs.update(_resolve_deps)
scala_repl = rule(
    implementation = _scala_repl_impl,
    attrs = _scala_repl_attrs,
    outputs = _common_outputs,
    executable = True,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

def _default_scala_extra_jars():
    return {
        "2.11": {
            "scalatest": {
                "version": "3.0.5",
                "sha256": "2aafeb41257912cbba95f9d747df9ecdc7ff43f039d35014b4c2a8eb7ed9ba2f",
            },
            "scalactic": {
                "version": "3.0.5",
                "sha256": "84723064f5716f38990fe6e65468aa39700c725484efceef015771d267341cf2",
            },
            "scala_xml": {
                "version": "1.0.5",
                "sha256": "767e11f33eddcd506980f0ff213f9d553a6a21802e3be1330345f62f7ee3d50f",
            },
            "scala_parser_combinators": {
                "version": "1.0.4",
                "sha256": "0dfaafce29a9a245b0a9180ec2c1073d2bd8f0330f03a9f1f6a74d1bc83f62d6",
            },
        },
        "2.12": {
            "scalatest": {
                "version": "3.0.5",
                "sha256": "b416b5bcef6720da469a8d8a5726e457fc2d1cd5d316e1bc283aa75a2ae005e5",
            },
            "scalactic": {
                "version": "3.0.5",
                "sha256": "57e25b4fd969b1758fe042595112c874dfea99dca5cc48eebe07ac38772a0c41",
            },
            "scala_xml": {
                "version": "1.0.5",
                "sha256": "035015366f54f403d076d95f4529ce9eeaf544064dbc17c2d10e4f5908ef4256",
            },
            "scala_parser_combinators": {
                "version": "1.0.4",
                "sha256": "282c78d064d3e8f09b3663190d9494b85e0bb7d96b0da05994fe994384d96111",
            },
        },
    }

def scala_repositories(
        scala_version_shas = (
            _default_scala_version(),
            _default_scala_version_jar_shas(),
        ),
        maven_servers = ["http://central.maven.org/maven2"],
        scala_extra_jars = _default_scala_extra_jars(),
        fetch_sources = False):
    (scala_version, scala_version_jar_shas) = scala_version_shas
    major_version = _extract_major_version(scala_version)

    _new_scala_default_repository(
        scala_version = scala_version,
        scala_version_jar_shas = scala_version_jar_shas,
        maven_servers = maven_servers,
        fetch_sources = fetch_sources,
    )

    scala_version_extra_jars = scala_extra_jars[major_version]

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scalatest",
        artifact = "org.scalatest:scalatest_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scalatest"]["version"],
        ),
        jar_sha256 = scala_version_extra_jars["scalatest"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scalactic",
        artifact = "org.scalactic:scalactic_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scalactic"]["version"],
        ),
        jar_sha256 = scala_version_extra_jars["scalactic"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_xml",
        artifact = "org.scala-lang.modules:scala-xml_{major_version}:{extra_jar_version}"
            .format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scala_xml"]["version"],
        ),
        jar_sha256 = scala_version_extra_jars["scala_xml"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_parser_combinators",
        artifact =
            "org.scala-lang.modules:scala-parser-combinators_{major_version}:{extra_jar_version}"
                .format(
                major_version = major_version,
                extra_jar_version = scala_version_extra_jars["scala_parser_combinators"]["version"],
            ),
        jar_sha256 = scala_version_extra_jars["scala_parser_combinators"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )

    _scala_maven_import_external(
        name = "scalac_rules_protobuf_java",
        artifact = "com.google.protobuf:protobuf-java:3.1.0",
        jar_sha256 = "8d7ec605ca105747653e002bfe67bddba90ab964da697aaa5daa1060923585db",
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )

    # used by ScalacProcessor
    _scala_maven_import_external(
        name = "scalac_rules_commons_io",
        artifact = "commons-io:commons-io:2.6",
        jar_sha256 = "f877d304660ac2a142f3865badfc971dec7ed73c747c7f8d5d2f5139ca736513",
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )

    # Template for binary launcher
    BAZEL_JAVA_LAUNCHER_VERSION = "0.17.1"
    java_stub_template_url = (
        "raw.githubusercontent.com/bazelbuild/bazel/" +
        BAZEL_JAVA_LAUNCHER_VERSION +
        "/src/main/java/com/google/devtools/build/lib/bazel/rules/java/" +
        "java_stub_template.txt"
    )
    http_file(
        name = "java_stub_template",
        urls = [
            "https://mirror.bazel.build/%s" % java_stub_template_url,
            "https://%s" % java_stub_template_url,
        ],
        sha256 =
            "39097bdc47407232e0fe7eed4f2c175c067b7eda95873cb76ffa76f1b4c18895",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
        actual = "@scalac_rules_protobuf_java//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/commons_io/commons_io",
        actual = "@scalac_rules_commons_io//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scalatest/scalatest",
        actual = "@io_bazel_rules_scala//scala/scalatest:scalatest",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_compiler",
        actual = "@io_bazel_rules_scala_scala_compiler",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_library",
        actual = "@io_bazel_rules_scala_scala_library",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_reflect",
        actual = "@io_bazel_rules_scala_scala_reflect",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_xml",
        actual = "@io_bazel_rules_scala_scala_xml",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/parser_combinators",
        actual = "@io_bazel_rules_scala_scala_parser_combinators",
    )

def _sanitize_string_for_usage(s):
    res_array = []
    for idx in range(len(s)):
        c = s[idx]
        if c.isalnum() or c == ".":
            res_array.append(c)
        else:
            res_array.append("_")
    return "".join(res_array)

# This auto-generates a test suite based on the passed set of targets
# we will add a root test_suite with the name of the passed name
def scala_test_suite(
        name,
        srcs = [],
        visibility = None,
        **kwargs):
    ts = []
    for test_file in srcs:
        n = "%s_test_suite_%s" % (name, _sanitize_string_for_usage(test_file))
        scala_test(
            name = n,
            srcs = [test_file],
            visibility = visibility,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    native.test_suite(name = name, tests = ts, visibility = visibility)

# Scala library suite generates a series of scala libraries
# then it depends on them with a meta one which exports all the sub targets
def scala_library_suite(
        name,
        srcs = [],
        exports = [],
        visibility = None,
        **kwargs):
    ts = []
    for src_file in srcs:
        n = "%s_lib_%s" % (name, _sanitize_string_for_usage(src_file))
        scala_library(
            name = n,
            srcs = [src_file],
            visibility = visibility,
            exports = exports,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    scala_library(
        name = name,
        deps = ts,
        exports = exports + ts,
        visibility = visibility,
    )

_scala_junit_test_attrs = {
    "prefixes": attr.string_list(default = []),
    "suffixes": attr.string_list(default = []),
    "suite_label": attr.label(
        default = Label(
            "//src/java/io/bazel/rulesscala/test_discovery:test_discovery",
        ),
    ),
    "suite_class": attr.string(
        default = "io.bazel.rulesscala.test_discovery.DiscoveredTestSuite",
    ),
    "print_discovered_classes": attr.bool(default = False, mandatory = False),
    "_junit": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/junit/junit",
        ),
    ),
    "_hamcrest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        ),
    ),
    "_bazel_test_runner": attr.label(
        default = Label(
            "@io_bazel_rules_scala//scala:bazel_test_runner_deploy",
        ),
        allow_files = True,
    ),
}
_scala_junit_test_attrs.update(_launcher_template)
_scala_junit_test_attrs.update(_implicit_deps)
_scala_junit_test_attrs.update(_common_attrs)
_scala_junit_test_attrs.update(_junit_resolve_deps)
_scala_junit_test_attrs.update({
    "tests_from": attr.label_list(providers = [[JavaInfo]]),
})
scala_junit_test = rule(
    implementation = _scala_junit_test_impl,
    attrs = _scala_junit_test_attrs,
    outputs = _common_outputs,
    test = True,
    fragments = ["java"],
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

def scala_specs2_junit_test(name, **kwargs):
    scala_junit_test(
        name = name,
        deps = _specs2_junit_dependencies() + kwargs.pop("deps", []),
        unused_dependency_checker_ignored_targets =
            _specs2_junit_dependencies() + kwargs.pop("unused_dependency_checker_ignored_targets", []),
        suite_label = Label(
            "//src/java/io/bazel/rulesscala/specs2:specs2_test_discovery",
        ),
        suite_class = "io.bazel.rulesscala.specs2.Specs2DiscoveredTestSuite",
        **kwargs
    )
