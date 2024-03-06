load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "check_expand_location",
    srcs = ["trivial.scala"],
    plugins = [
        ":check_expand_location_plugin_deploy.jar",
    ],
    scalacopts = [
        "-P:diablerie:location=$(location :check_expand_location_plugin_deploy.jar)",
    ],
)

scala_library(
    name = "check_expand_location_plugin",
    srcs = [
        "check_expand_location_plugin.scala",
    ],
    resource_strip_prefix = package_name(),
    resources = [
        ":gen-scalac-plugin.xml",
    ],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
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
