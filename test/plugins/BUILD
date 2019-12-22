load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "usage",
    srcs = ["usage.scala"],
    plugins = [
        ":plugin_deploy.jar",
    ],
    scalacopts = [
        "-P:diablerie:location=$(location :plugin_deploy.jar)",
    ],
)

scala_library(
    name = "plugin",
    srcs = [
        "plugin.scala",
    ],
    resource_strip_prefix = package_name(),
    resources = [
        ":gen-scalac-plugin.xml",
    ],
    deps = [
        "@io_bazel_rules_scala_scala_compiler",
    ],
)

_gen_plugin_xml_cmd = """
cat > $@ << EOF
<plugin>
  <name>plugin</name>
  <classname>plugin.Plugin</classname>
</plugin>
"""

genrule(
    name = "gen-scalac-plugin.xml",
    outs = ["scalac-plugin.xml"],
    cmd = _gen_plugin_xml_cmd,
)
