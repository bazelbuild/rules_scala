def scalapb_register_toolchains():
    native.register_toolchains("@io_bazel_rules_scala//scalapb:default_toolchain")

def scalapb_register_enable_all_options_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//scalapb:enable_all_options_toolchain")

