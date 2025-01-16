load("//scala:providers.bzl", "ScalaInfo")

def _phase_scalainfo_provider_implementation(contains_macros):
    return struct(
        external_providers = {
            "ScalaInfo": ScalaInfo(contains_macros = contains_macros),
        },
    )

def phase_scalainfo_provider_macro(ctx, p):
    return _phase_scalainfo_provider_implementation(contains_macros = True)

def phase_scalainfo_provider_non_macro(ctx, p):
    return _phase_scalainfo_provider_implementation(contains_macros = False)
