load(
    "//scala:scala_cross_version.bzl",
    "extract_major_version",
    "extract_minor_version",
    "version_suffix",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
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
_COMPILER_SOURCE_ALIAS_TEMPLATE = """alias(
    name = "src",
    visibility = ["//visibility:public"],
    actual = select({{{compiler_sources}
    }}),
)
"""

_COMPILER_SOURCES_ENTRY_TEMPLATE = """
        "@io_bazel_rules_scala_config//:scala_version{scala_version_suffix}":
            "@scala_compiler_source{scala_version_suffix}//:src","""

def _compiler_sources_repo_impl(rctx):
    sources = [
        _COMPILER_SOURCES_ENTRY_TEMPLATE.format(
            scala_version_suffix = version_suffix(scala_version),
        )
        for scala_version in SCALA_VERSIONS
    ]
    build_content = _COMPILER_SOURCE_ALIAS_TEMPLATE.format(
        compiler_sources = "".join(sources),
    )
    rctx.file("BUILD", content = build_content, executable = False)

compiler_sources_repo = repository_rule(
    implementation = _compiler_sources_repo_impl,
    attrs = {
        "scala_versions": attr.string_list(mandatory = True),
    },
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
    patch = Label("//dt_patches:dt_compiler_%s.patch" % scala_major_version)

    minor_version = int(scala_minor_version)

    if scala_major_version == "2.12":
        if minor_version >= 1 and minor_version <= 7:
            patch = Label(
                "//dt_patches:dt_compiler_%s.1.patch" % scala_major_version,
            )
        elif minor_version <= 11:
            patch = Label(
                "//dt_patches:dt_compiler_%s.8.patch" % scala_major_version,
            )
    elif scala_major_version.startswith("3."):
        patch = Label("//dt_patches:dt_compiler_3.patch")

    build_file_content = "\n".join([
        "package(default_visibility = [\"//visibility:public\"])",
        "filegroup(",
        "    name = \"src\",",
        "    srcs=[\"scala/tools/nsc/symtab/SymbolLoaders.scala\"]," if scala_major_version.startswith("2.") else "    srcs=[\"dotty/tools/dotc/core/SymbolLoaders.scala\"],",
        ")",
    ])
    default_scalac_srcjar = {
        "url": "https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/%s/scala-compiler-%s-sources.jar" % (scala_version, scala_version) if scala_major_version.startswith("2.") else "https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_3/%s/scala3-compiler_3-%s-sources.jar" % (scala_version, scala_version),
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

def load_rules_dependencies():
    if not native.existing_rule("bazel_skylib"):
        http_archive(
            name = "bazel_skylib",
            sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            ],
        )

    # Needed by protobuf-21.7 and Bazel 6.5.0, as later versions require C++14.
    if not native.existing_rule("com_google_absl"):
        http_archive(
            name = "com_google_absl",
            sha256 = "91ac87d30cc6d79f9ab974c51874a704de9c2647c40f6932597329a282217ba8",
            strip_prefix = "abseil-cpp-20220623.1",
            url = "https://github.com/abseil/abseil-cpp/archive/refs/tags/20220623.1.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "75be42bd736f4df6d702a0e4e4d30de9ee40eac024c4b845d17ae4cc831fe4ae",
            strip_prefix = "protobuf-21.7",
            url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v21.7.tar.gz",
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
                "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
            ],
            sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        )

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "6fb6767d1bef535310547e03247f7518b03487740c11b6c6adb7952033fe1295",
            strip_prefix = "rules_proto-6.0.2",
            url = "https://github.com/bazelbuild/rules_proto/releases/download/6.0.2/rules_proto-6.0.2.tar.gz",
        )

def setup_scala_compiler_sources(srcjars = {}):
    """Generates Scala compiler source repos used internally by rules_scala.

    Args:
        srcjars: optional dictionary of Scala version string to compiler srcjar
            metadata dictionaries containing:
            - exactly one "label", "url", or "urls" key
            - optional "integrity" or "sha256" keys
    """
    for scala_version in SCALA_VERSIONS:
        dt_patched_compiler_setup(scala_version, srcjars.get(scala_version))

    compiler_sources_repo(
        name = "scala_compiler_sources",
        scala_versions = SCALA_VERSIONS,
    )

def rules_scala_setup(scala_compiler_srcjar = None):
    load_rules_dependencies()
    setup_scala_compiler_sources({
        version: scala_compiler_srcjar
        for version in SCALA_VERSIONS
    })

def _artifact_ids(scala_version):
    result = [
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_parser_combinators",
        "io_bazel_rules_scala_scala_xml",
        "org_scala_lang_modules_scala_collection_compat",
    ]

    if scala_version.startswith("2."):
        result.extend([
            "io_bazel_rules_scala_scala_reflect",
            "org_scalameta_semanticdb_scalac",
        ])

    if scala_version.startswith("2.13.") or scala_version.startswith("3."):
        # Since the Scala 2.13 compiler is included in Scala 3 deps.
        result.extend([
            "io_github_java_diff_utils_java_diff_utils",
            "net_java_dev_jna_jna",
            "org_jline_jline",
        ])

    if scala_version.startswith("3."):
        result.extend([
            "io_bazel_rules_scala_scala_asm",
            "io_bazel_rules_scala_scala_compiler_2",
            "io_bazel_rules_scala_scala_interfaces",
            "io_bazel_rules_scala_scala_library_2",
            "io_bazel_rules_scala_scala_reflect_2",
            "io_bazel_rules_scala_scala_tasty_core",
            "org_jline_jline_native",
            "org_jline_jline_reader",
            "org_jline_jline_terminal",
            "org_jline_jline_terminal_jna",
            "org_scala_sbt_compiler_interface",
            "org_scala_sbt_util_interface",
        ])

    return result

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
        fetch_sources = False,
        validate_scala_version = True,
        scala_compiler_srcjars = {}):
    if load_dep_rules:
        # When `WORKSPACE` goes away, so can this case.
        load_rules_dependencies()

    setup_scala_compiler_sources(scala_compiler_srcjars)

    if load_jar_deps:
        rules_scala_toolchain_deps_repositories(
            maven_servers,
            overriden_artifacts,
            fetch_sources,
            validate_scala_version,
        )
