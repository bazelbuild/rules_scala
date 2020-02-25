#
# PHASE: coverage
#
# DOCUMENT THIS
#

load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
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
    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0 or not ctx.configuration.coverage_enabled:
        return struct(
            replacements = {},
            external_providers = {},
        )
    else:
        input_jar = ctx.outputs.jar
        output_jar = ctx.actions.declare_file(
            "{}-offline.jar".format(input_jar.basename.split(".")[0]),
        )
        src_paths = [src.path for src in ctx.files.srcs]
        records = [
            (input_jar, output_jar, srcs_paths),
        ]

        args = ctx.actions.args()
        args.add_all(records, map_each = _jacoco_offline_instrument_format_each)
        args.set_param_file_format("multiline")
        args.use_param_file("@%s", use_always = True)

        ctx.actions.run(
            mnemonic = "JacocoInstrumenter",
            inputs = [record[0] for record in records],
            outputs = [record[1] for record in records],
            executable = ctx.attr._code_coverage_instrumentation_worker.files_to_run,
            execution_requirements = {"supports-workers": "1"},
            arguments = [args],
        )

        replacements = {i: o for (i, o, _) in records}
        provider = _coverage_replacements_provider.create(
            replacements = replacements,
        )
        instrumented_files_provider = coverage_common.instrumented_files_info(
            ctx,
            source_attributes = ["srcs"],
            dependency_attributes = _coverage_replacements_provider.dependency_attributes,
            extensions = ["scala", "java"],
        )
        return struct(
            replacements = replacements,
            external_providers = {
                "_CoverageReplacements": provider,
                "InstrumentedFilesInfo": instrumented_files_provider,
            },
        )

def _jacoco_offline_instrument_format_each(records):
    return (["%s=%s=%s" % (records[0].path, records[1].path, ",".join(records[2]))])
