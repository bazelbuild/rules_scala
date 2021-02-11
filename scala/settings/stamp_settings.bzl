StampScalaImport = provider(fields = ["enabled"])

def _impl(ctx):
    return StampScalaImport(enabled = ctx.build_setting_value)

stamp_scala_import = rule(
    implementation = _impl,
    build_setting = config.bool(flag = True),
)
