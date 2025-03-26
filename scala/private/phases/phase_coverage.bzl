#
# PHASE: coverage
#
# DOCUMENT THIS
#

load(
    "//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)

def phase_coverage_library(ctx, p):
    args = struct(
        srcjars = p.collect_srcjars,
    )
    return _phase_coverage_default(ctx, p, args)

def phase_coverage_common(ctx, p):
    return _phase_coverage_default(ctx, p)

def _phase_coverage_default(ctx, p, _args = struct()):
    return _phase_coverage(
        ctx,
        p,
        _args.srcjars if hasattr(_args, "srcjars") else depset(),
    )

def _phase_coverage(ctx, p, srcjars):
    instrumented_files_provider = coverage_common.instrumented_files_info(
        ctx,
        source_attributes = ["srcs"],
        dependency_attributes = _coverage_replacements_provider.dependency_attributes,
        extensions = ["scala", "java"],
    )
    external_providers = {
        "InstrumentedFilesInfo": instrumented_files_provider,
    }

    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0 or not ctx.coverage_instrumented():
        return struct(
            replacements = {},
            external_providers = external_providers,
        )
    else:
        input_jar = ctx.outputs.jar
        output_jar = ctx.actions.declare_file(
            "{}-offline.jar".format(input_jar.basename.split(".")[0]),
        )

        args = ctx.actions.args()
        args.set_param_file_format("multiline")
        args.use_param_file("@%s", use_always = True)
        args.add(input_jar)
        args.add(output_jar)
        args.add_all(ctx.files.srcs)

        ctx.actions.run(
            mnemonic = "JacocoInstrumenter",
            inputs = [input_jar],
            outputs = [output_jar],
            executable = ctx.attr._code_coverage_instrumentation_worker.files_to_run,
            execution_requirements = {"supports-workers": "1"},
            arguments = [args],
        )

        replacements = {input_jar: output_jar}
        provider = _coverage_replacements_provider.create(
            replacements = replacements,
        )
        external_providers["_CoverageReplacements"] = provider
        return struct(
            replacements = replacements,
            external_providers = external_providers,
        )
