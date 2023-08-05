load(
    "@io_bazel_rules_scala//scala/private/toolchain_deps:toolchain_deps.bzl",
    "find_deps_info_on",
)
load("@io_bazel_rules_scala//scala:semanticdb_provider.bzl", "SemanticdbInfo")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")
load("@bazel_skylib//lib:paths.bzl", "paths")

def phase_semanticdb(ctx, p):
    #semanticdb_bundle_in_jar feature: enables bundling the semanticdb files within the output jar.

    #Scala 2: Uses the semanticdb compiler plugin. Will output semanticdb files into the specified 'targetroot' which defaults to be under the '_scalac/classes' dir. When targetroot is under the _scalac/classes dir scalac bundles the *.semanticdb files into the jar.

    #Scala3: Semanticdb is built into scalac. Currently, if semanticdb-target is used, the semanticdb files are written and not bundled, otherwise, the semanticdb files are not written as files and only available inside the jar.

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    toolchain_type_label = "@io_bazel_rules_scala//scala:toolchain_type"

    if toolchain.enable_semanticdb == True:
        scalacopts = []
        semanticdb_deps = []
        output_files = []
        plugin_jar_path = ""

        target_output_path = paths.dirname(ctx.outputs.jar.path)

        semanticdb_intpath = "_scalac/" + ctx.label.name + "/classes" if toolchain.semanticdb_bundle_in_jar == True else "semanticdb/" + ctx.label.name

        semanticdb_target_root = "%s/%s" % (target_output_path, semanticdb_intpath)

        #declare all the semanticdb files
        if (not toolchain.semanticdb_bundle_in_jar):
            semanticdb_outpath = "META-INF/semanticdb"

            for currSrc in ctx.files.srcs:
                if currSrc.extension == "scala":
                    outputfilename = "%s/%s/%s.semanticdb" % (semanticdb_intpath, semanticdb_outpath, currSrc.path)
                    output_files.append(ctx.actions.declare_file(outputfilename))

        if SCALA_MAJOR_VERSION.startswith("2"):
            semanticdb_deps = find_deps_info_on(ctx, toolchain_type_label, "scala_semanticdb").deps

            if len(semanticdb_deps) == 0:
                fail("semanticdb enabled, but semanticdb plugin jar not specified in scala_toolchain")
            if len(semanticdb_deps) != 1:
                fail("more than one semanticdb plugin jar was specified in scala_toolchain. Expect a single semanticdb plugin jar")

            plugin_jar_path = semanticdb_deps[0][JavaInfo].java_outputs[0].class_jar.path

            scalacopts += [
                #note: Xplugin parameter handled in scalacworker,
                "-Yrangepos",
                "-P:semanticdb:failures:error",
                "-P:semanticdb:targetroot:" + semanticdb_target_root,
            ]
        else:
            #Note: In Scala3, semanticdb is built-in to compiler, so no need for plugin

            scalacopts.append("-Ysemanticdb")

            if toolchain.semanticdb_bundle_in_jar == False:
                scalacopts.append("-semanticdb-target:" + semanticdb_target_root)

        semanticdb_provider = SemanticdbInfo(
            semanticdb_enabled = True,
            target_root = None if toolchain.semanticdb_bundle_in_jar else semanticdb_target_root,
            is_bundled_in_jar = toolchain.semanticdb_bundle_in_jar,
            plugin_jar = plugin_jar_path,
        )

        return struct(
            scalacopts = scalacopts,
            plugin = semanticdb_deps,
            outputs = output_files,
            external_providers = {"SemanticdbInfo": semanticdb_provider},
        )

    return None
