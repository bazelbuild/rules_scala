#
# PHASE: coverage
#
# DOCUMENT THIS
#

load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)

_empty_coverage_struct = struct(
    external = struct(
        replacements = {},
    ),
    providers_dict = {},
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
    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0 or
            not ctx.configuration.coverage_enabled or
            not hasattr(ctx.attr, "_code_coverage_instrumentation_worker"):
        coverage = _empty_coverage_struct
    else:
        coverage = _jacoco_offline_instrument(ctx, ctx.outputs.jar)

    return struct(
        coverage = coverage.external,
        external_providers = coverage.providers_dict,
    )

def _jacoco_offline_instrument(ctx, input_jar):
    output_jar = ctx.actions.declare_file(
        "{}-offline.jar".format(input_jar.basename.split(".")[0]),
    )
    in_out_pairs = [
        (input_jar, output_jar),
    ]

    args = ctx.actions.args()
    args.add_all(in_out_pairs, map_each = _jacoco_offline_instrument_format_each)
    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)

    ctx.actions.run(
        mnemonic = "JacocoInstrumenter",
        inputs = [in_out_pair[0] for in_out_pair in in_out_pairs],
        outputs = [in_out_pair[1] for in_out_pair in in_out_pairs],
        executable = ctx.attr._code_coverage_instrumentation_worker.files_to_run,
        execution_requirements = {"supports-workers": "1"},
        arguments = [args],
    )

    replacements = {i: o for (i, o) in in_out_pairs}
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
        external = struct(
            replacements = replacements,
        ),
        providers_dict = {
            "_CoverageReplacements": provider,
            "InstrumentedFilesInfo": instrumented_files_provider,
        },
    )

def _jacoco_offline_instrument_format_each(in_out_pair):
    return (["%s=%s" % (in_out_pair[0].path, in_out_pair[1].path)])
