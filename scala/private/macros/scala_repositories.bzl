load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    "extract_major_version",
    "extract_minor_version",
    "version_suffix",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def _dt_patched_compiler_impl(rctx):
    # Need to give the file a .zip extension so rctx.extract knows what type of archive it is
    rctx.symlink(rctx.attr.srcjar, "file.zip")
    rctx.extract(archive = "file.zip")
    rctx.patch(rctx.attr.patch)
    rctx.file("BUILD", content = rctx.attr.build_file_content)

dt_patched_compiler = repository_rule(
    attrs = {
        "patch": attr.label(),
        "srcjar": attr.label(),
        "build_file_content": attr.string(),
    },
    implementation = _dt_patched_compiler_impl,
)

def _validate_scalac_srcjar(srcjar):
    if type(srcjar) != "dict":
        return False
    oneof = ["url", "urls", "label"]
    count = 0
    for key in oneof:
        if key in srcjar:
            count += 1
    return count == 1

def dt_patched_compiler_setup(scala_version, scala_compiler_srcjar = None):
    scala_major_version = extract_major_version(scala_version)
    scala_minor_version = extract_minor_version(scala_version)
    patch = "@io_bazel_rules_scala//dt_patches:dt_compiler_%s.patch" % scala_major_version

    minor_version = int(scala_minor_version)

    if scala_major_version == "2.12":
        if minor_version >= 1 and minor_version <= 7:
            patch = "@io_bazel_rules_scala//dt_patches:dt_compiler_%s.1.patch" % scala_major_version
        elif minor_version <= 11:
            patch = "@io_bazel_rules_scala//dt_patches:dt_compiler_%s.8.patch" % scala_major_version

    build_file_content = "\n".join([
        "package(default_visibility = [\"//visibility:public\"])",
        "filegroup(",
        "    name = \"src\",",
        "    srcs=[\"scala/tools/nsc/symtab/SymbolLoaders.scala\"],",
        ")",
    ])
    default_scalac_srcjar = {
        "url": "https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/%s/scala-compiler-%s-sources.jar" % (scala_version, scala_version),
    }
    srcjar = scala_compiler_srcjar if scala_compiler_srcjar != None else default_scalac_srcjar
    _validate_scalac_srcjar(srcjar) or fail(
        ("scala_compiler_srcjar invalid, must be a dict with exactly one of \"label\", \"url\"" +
         " or \"urls\" keys, got: ") + repr(srcjar),
    )
    if "label" in srcjar:
        dt_patched_compiler(
            name = "scala_compiler_source" + version_suffix(scala_version),
            build_file_content = build_file_content,
            patch = patch,
            srcjar = srcjar["label"],
        )
    else:
        http_archive(
            name = "scala_compiler_source" + version_suffix(scala_version),
            build_file_content = build_file_content,
            patches = [patch],
            url = srcjar.get("url"),
            urls = srcjar.get("urls"),
            sha256 = srcjar.get("sha256"),
            integrity = srcjar.get("integrity"),
        )

def rules_scala_setup(scala_compiler_srcjar = None):
    if not native.existing_rule("bazel_skylib"):
        http_archive(
            name = "bazel_skylib",
            sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.4.1.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            ],
        )

    if not native.existing_rule("rules_cc"):
        http_archive(
            name = "rules_cc",
            urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.10/rules_cc-0.0.10.tar.gz"],
            sha256 = "65b67b81c6da378f136cc7e7e14ee08d5b9375973427eceb8c773a4f69fa7e49",
            strip_prefix = "rules_cc-0.0.10",
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
            ],
            sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        )

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "6fb6767d1bef535310547e03247f7518b03487740c11b6c6adb7952033fe1295",
            strip_prefix = "rules_proto-6.0.2",
            urls = [
                "https://github.com/bazelbuild/rules_proto/releases/download/6.0.2/rules_proto-6.0.2.tar.gz",
            ],
        )

    for scala_version in SCALA_VERSIONS:
        dt_patched_compiler_setup(scala_version, scala_compiler_srcjar)

def _artifact_ids(scala_version):
    return [
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_reflect",
        "io_bazel_rules_scala_scala_xml",
        "io_bazel_rules_scala_scala_parser_combinators",
        "org_scalameta_semanticdb_scalac",
    ] if scala_version.startswith("2") else [
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_interfaces",
        "io_bazel_rules_scala_scala_tasty_core",
        "io_bazel_rules_scala_scala_asm",
        "io_bazel_rules_scala_scala_xml",
        "io_bazel_rules_scala_scala_parser_combinators",
        "io_bazel_rules_scala_scala_library_2",
        "org_scala_sbt_compiler_interface",
    ]

def rules_scala_toolchain_deps_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {},
        fetch_sources = False,
        validate_scala_version = True):
    for scala_version in SCALA_VERSIONS:
        repositories(
            scala_version = scala_version,
            for_artifact_ids = _artifact_ids(scala_version),
            maven_servers = maven_servers,
            fetch_sources = fetch_sources,
            overriden_artifacts = overriden_artifacts,
            validate_scala_version = validate_scala_version,
        )

def scala_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {},
        load_dep_rules = True,
        load_jar_deps = True,
        fetch_sources = False):
    if load_dep_rules:
        rules_scala_setup()

    if load_jar_deps:
        rules_scala_toolchain_deps_repositories(
            maven_servers,
            overriden_artifacts,
            fetch_sources,
        )
