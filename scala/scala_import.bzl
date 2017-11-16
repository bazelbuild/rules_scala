def _scala_import_impl(ctx):
    target_data = _code_jars_and_intellij_metadata_from(ctx.attr.jars)
    (code_jars, intellij_metadata) = (target_data.code_jars, target_data.intellij_metadata)
    jars2labels = _add_labels_of_current_code_jars(code_jars, ctx.label)
    code_jars_depset = depset(code_jars)
    transitive_runtime_jars = _collect_runtime(ctx.attr.runtime_deps)
    jars = _collect(ctx.attr.deps, jars2labels)
    return struct(
        scala = struct(
          outputs = struct (
              jars = intellij_metadata
          ),
        ),
        jars_to_labels = jars2labels,
        providers = [
            _create_provider(code_jars_depset, transitive_runtime_jars, jars)
        ],
    )
def _create_provider(code_jars_depset, transitive_runtime_jars, jars):
  test_provider = java_common.create_provider()
  if hasattr(test_provider, "full_compile_jars"):
      return java_common.create_provider(
          use_ijar = False,
          compile_time_jars = code_jars_depset,
          runtime_jars = transitive_runtime_jars + jars.transitive_runtime_jars,
          transitive_compile_time_jars = jars.transitive_compile_jars + code_jars_depset,
          transitive_runtime_jars = transitive_runtime_jars + jars.transitive_runtime_jars + code_jars_depset,
      )
  else:
      return java_common.create_provider(
          compile_time_jars = code_jars_depset,
          runtime_jars = transitive_runtime_jars + jars.transitive_runtime_jars,
          transitive_compile_time_jars = jars.transitive_compile_jars + code_jars_depset,
          transitive_runtime_jars = transitive_runtime_jars + jars.transitive_runtime_jars + code_jars_depset,
      )

def _add_labels_of_current_code_jars(code_jars, label):
  jars2labels = {}
  for jar in code_jars:
    jars2labels[jar.path] = label
  return jars2labels

def _code_jars_and_intellij_metadata_from(jars):
  code_jars = []
  intellij_metadata = []
  for jar in jars:
    current_jar_code_jars = _filter_out_non_code_jars(jar.files)
    code_jars += current_jar_code_jars
    for current_class_jar in current_jar_code_jars:
      intellij_metadata.append(struct(
           ijar = None,
           class_jar = current_class_jar,
       )
     )
  print(intellij_metadata)
  return struct(code_jars = code_jars, intellij_metadata = intellij_metadata)

def _filter_out_non_code_jars(files):
  return [file for file in files if not _is_source_jar(file)]

def _is_source_jar(file):
  return file.basename.endswith("-sources.jar")

def _collect(deps, jars2labels):
  transitive_compile_jars = depset()
  runtime_jars = depset()

  for dep_target in deps:
      java_provider = dep_target[java_common.provider]
      transitive_compile_jars += java_provider.transitive_compile_time_jars
      runtime_jars += java_provider.transitive_runtime_jars
      if hasattr(dep_target, "jars_to_labels"):  #transitively accumulate labels
        jars2labels.update(dep_target.jars_to_labels)
      else:
        for jar in java_provider.compile_jars:
          jars2labels[jar.path] = dep_target.label

  return struct(transitive_runtime_jars = runtime_jars, transitive_compile_jars = transitive_compile_jars)

def _collect_runtime(runtime_deps):
  runtime_jars = depset()

  for dep_target in runtime_deps:
      java_provider = dep_target[java_common.provider]
      runtime_jars += java_provider.transitive_runtime_jars

  return runtime_jars


scala_import = rule(
  implementation=_scala_import_impl,
  attrs={
      "jars": attr.label_list(),
      "deps": attr.label_list(),
      "runtime_deps": attr.label_list()
      },
)
