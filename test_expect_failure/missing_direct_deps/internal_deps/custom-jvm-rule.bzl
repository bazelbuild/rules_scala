def _custom_jvm_impl(ctx):
    print(ctx.label)
    transitive_compile_jars = _collect(ctx.attr.deps)
    return struct(
        providers = [
          java_common.create_provider(
              transitive_compile_time_jars = transitive_compile_jars,
          )
        ],
    )

def _collect(deps):
  transitive_compile_jars = depset()
  for dep_target in deps:
      transitive_compile_jars += dep_target[java_common.provider].transitive_compile_time_jars
  return transitive_compile_jars

custom_jvm = rule(
  implementation=_custom_jvm_impl,
  attrs={
      "deps": attr.label_list(),
      },
)