#intellij part is tested manually, tread lightly when changing there
#if you change make sure to manually re-import an intellij project and see imports
#are resolved (not red) and clickable
def _scala_import_impl(ctx):
    intellij_metadata = _intellij_metadata_from(ctx.attr.jars)

    jars_provider = _jars_to_provider(ctx.attr.jars)

    deps_provider = _labels_to_provider(ctx.attr.deps)
    runtime_deps_provider = _labels_to_provider(ctx.attr.runtime_deps)
    exports_provider = _labels_to_provider(ctx.attr.exports)

    jars2labels = _collect_jar_labels(ctx)
    _add_labels_of_current_code_jars(depset(transitive=[jars_provider.full_compile_jars, exports_provider.full_compile_jars]), ctx.label, jars2labels) #last to override the label of the export compile jars to the current target

    return struct(
        scala = struct(
          outputs = struct (
              jars = intellij_metadata
          ),
        ),
        jars_to_labels = jars2labels,
        providers = [
            java_common.merge([jars_provider, deps_provider, runtime_deps_provider, exports_provider])
        ],
    )

def _jars_to_provider(jars):
  providers = []
  for jar in jars:
    if JavaInfo in jar:
      fail("jars must contain only jar files")

    code_jars = _filter_out_non_code_jars(jar.files)

    for code_jar in code_jars:
      providers.append(_jar_to_provider(code_jar))

  return java_common.merge(providers)

def _jar_to_provider(jar):
  return JavaInfo(
      output_jar = jar,
      compile_jar = jar,
  )

def _collect_jar_labels(ctx):
  jars2labels = {}
  _collect_labels(ctx.attr.deps, jars2labels)
  _collect_labels(ctx.attr.exports, jars2labels) #untested
  return jars2labels

def _collect_labels(deps, jars2labels):
  for dep_target in deps:
      java_provider = dep_target[JavaInfo]
      _transitively_accumulate_labels(dep_target, java_provider, jars2labels)

def _add_labels_of_current_code_jars(code_jars, label, jars2labels):
  for jar in code_jars.to_list():
    jars2labels[jar.path] = label

def _intellij_metadata_from(jars):
  intellij_metadata = []
  for jar in jars:
    current_jar_code_jars = _filter_out_non_code_jars(jar.files)
    for current_class_jar in current_jar_code_jars: #intellij, untested
      intellij_metadata.append(struct(
           ijar = None,
           class_jar = current_class_jar,
           source_jar = None,
           source_jars = [],
       )
     )
  return intellij_metadata

def _filter_out_non_code_jars(files):
  return [file for file in files.to_list() if not _is_source_jar(file)]

def _is_source_jar(file):
  return file.basename.endswith("-sources.jar")

def _labels_to_provider(labels):
  providers = []
  for label in labels:
    providers.append(label[JavaInfo])

  return java_common.merge(providers)


def _transitively_accumulate_labels(dep_target, java_provider, jars2labels):
  if hasattr(dep_target, "jars_to_labels"):
    jars2labels.update(dep_target.jars_to_labels)
  #scala_library doesn't add labels to the direct dependency itself
  for jar in java_provider.compile_jars.to_list():
    jars2labels[jar.path] = dep_target.label

scala_import = rule(
  implementation=_scala_import_impl,
  attrs={
      "jars": attr.label_list(allow_files=True), #current hidden assumption is that these point to full, not ijar'd jars
      "deps": attr.label_list(),
      "runtime_deps": attr.label_list(),
      "exports": attr.label_list()
      },
)
