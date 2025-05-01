load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")

def import_compiler_user_srcjar_repos():
    http_jar(
        name = "scala_compiler_srcjar",
        sha256 = "95c217cc87ee846b39990e0a9c273824a384dffbac57df84d466f866df4a91ea",
        url = "https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/2.12.16/scala-compiler-2.12.16-sources.jar",
    )

    http_jar(
        name = "scala3_compiler_srcjar",
        sha256 = "3c413efa9a2921ef59da7f065c445ae1b6b97057cbbc6b16957ad052a575a3ce",
        url = "https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_3/3.4.3/scala3-compiler_3-3.4.3-sources.jar",
    )

def _compiler_user_srcjar_repos_impl(_ctx):
    import_compiler_user_srcjar_repos()

compiler_user_srcjar_repos = module_extension(
    implementation = _compiler_user_srcjar_repos_impl,
)
