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
            sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            ],
        )

    if not native.existing_rule("rules_cc"):
        http_archive(
            name = "rules_cc",
            urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.6/rules_cc-0.0.6.tar.gz"],
            sha256 = "3d9e271e2876ba42e114c9b9bc51454e379cbf0ec9ef9d40e2ae4cec61a31b40",
            strip_prefix = "rules_cc-0.0.6",
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/5.4.1/rules_java-5.4.1.tar.gz",
            ],
            sha256 = "a1f82b730b9c6395d3653032bd7e3a660f9d5ddb1099f427c1e1fe768f92e395",
        )

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "dc3fb206a2cb3441b485eb1e423165b231235a1ea9b031b4433cf7bc1fa460dd",
            strip_prefix = "rules_proto-5.3.0-21.7",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/refs/tags/5.3.0-21.7.tar.gz",
                "https://github.com/bazelbuild/rules_proto/archive/refs/tags/5.3.0-21.7.tar.gz",
            ],
        )

    for scala_version in SCALA_VERSIONS:
        dt_patched_compiler_setup(scala_version, scala_compiler_srcjar)

def _artifact_ids(scala_version):
    scala_2_artifact_ids = [
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_reflect",
        "io_bazel_rules_scala_scala_xml",
        "io_bazel_rules_scala_scala_parser_combinators",
        "org_scalameta_semanticdb_scalac"]

    scala_3_artifact_ids = [
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_interfaces",
        "io_bazel_rules_scala_scala_tasty_core",
        "io_bazel_rules_scala_scala_asm",
        "io_bazel_rules_scala_scala_xml",
        "io_bazel_rules_scala_scala_parser_combinators",
        "io_bazel_rules_scala_scala_library_2"]

    scala_3_4_artifact_ids = scala_3_artifact_ids + ["org_scala_sbt_compiler_interface"]

    # Need to add additional artifact for scala versions >= 3.4.0
    scala_3_x_artifact_ids = scala_3_4_artifact_ids if scala_version.split('.')[1] >= '4' else scala_3_artifact_ids

    return scala_2_artifact_ids if scala_version.startswith("2") else scala_3_x_artifact_ids

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
