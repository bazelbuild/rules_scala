SemanticdbInfo = provider(
    fields = {
        "semanticdb_enabled": "boolean",
        "target_root": "directory containing the semanticdb files (relative to execroot).",
        "is_bundled_in_jar": "boolean: whether the semanticdb files are bundled inside the jar",
        "plugin_jar": "semanticdb plugin jar file",
    },
)
