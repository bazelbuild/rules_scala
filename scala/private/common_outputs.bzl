"""Common outputs used in rule outputs"""

common_outputs = {
    "jar": "%{name}.jar",
    "deploy_jar": "%{name}_deploy.jar",
    "external_deps_component_jar": "%{name}_external_deps_component.jar",
    "internal_deps_component_jar": "%{name}_internal_deps_component.jar",
    "manifest": "%{name}_MANIFEST.MF",
    "statsfile": "%{name}.statsfile",
    "diagnosticsfile": "%{name}.diagnosticsproto",
}
