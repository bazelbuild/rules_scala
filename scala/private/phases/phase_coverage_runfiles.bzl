#
# PHASE: coverage runfiles
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)

def phase_coverage_runfiles(ctx, p):
    coverage_runfiles = []
    rjars = p.compile.rjars
    if ctx.configuration.coverage_enabled:
        coverage_replacements = _coverage_replacements_provider.from_ctx(
            ctx,
            base = p.coverage.replacements if ctx.coverage_instrumented() else {},
        ).replacements

        rjars = depset([
            coverage_replacements[jar] if jar in coverage_replacements else jar
            for jar in rjars.to_list()
        ])
        coverage_runfiles = ctx.files.jacocorunner + ctx.files._lcov_merger + coverage_replacements.values()
    return struct(
        coverage_runfiles = coverage_runfiles,
        runfiles = depset(coverage_runfiles),
        rjars = rjars,
    )
