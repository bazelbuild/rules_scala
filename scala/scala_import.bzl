#intellij part is tested manually, tread lightly when changing there
#if you change make sure to manually re-import an intellij project and see imports
#are resolved (not red) and clickable
def _scala_import_impl(ctx):
    target_data = _code_jars_and_intellij_metadata_from(ctx.attr.jars)
    (current_target_compile_jars, intellij_metadata) = (target_data.code_jars, target_data.intellij_metadata)
    current_jars = depset(current_target_compile_jars)
    exports = _collect(ctx.attr.exports)
    transitive_runtime_jars = _collect_runtime(ctx.attr.runtime_deps)
    jars = _collect(ctx.attr.deps)
    jars2labels = {}
    _collect_labels(ctx.attr.deps, jars2labels)
    _collect_labels(ctx.attr.exports, jars2labels) #untested
    _add_labels_of_current_code_jars(depset(transitive=[current_jars, exports.compile_jars]), ctx.label, jars2labels) #last to override the label of the export compile jars to the current target
    return struct(
        scala = struct(
          outputs = struct (
              jars = intellij_metadata
          ),
        ),
        jars_to_labels = jars2labels,
        providers = [
            _create_provider(current_jars, transitive_runtime_jars, jars, exports)
        ],
    )
def _create_provider(current_target_compile_jars, transitive_runtime_jars, jars, exports):
    return JavaInfo(
        use_ijar = False,
        dpes = depset(transitive = [jars.transitive_compile_jars, current_target_compile_jars, exports.transitive_compile_jars, exports.compile_jars]),
        runtime_deps = depset(transitive = [transitive_runtime_jars, jars.transitive_runtime_jars, current_target_compile_jars, exports.transitive_runtime_jars]),
    )

def _add_labels_of_current_code_jars(code_jars, label, jars2labels):
  for jar in code_jars.to_list():
    jars2labels[jar.path] = label

def _code_jars_and_intellij_metadata_from(jars):
  code_jars = []
  intellij_metadata = []
  for jar in jars:
    current_jar_code_jars = _filter_out_non_code_jars(jar.files)
    code_jars += current_jar_code_jars
    for current_class_jar in current_jar_code_jars: #intellij, untested
      intellij_metadata.append(struct(
           ijar = None,
           class_jar = current_class_jar,
           source_jar = None,
           source_jars = [],
       )
     )
  return struct(code_jars = code_jars, intellij_metadata = intellij_metadata)

def _filter_out_non_code_jars(files):
  return [file for file in files.to_list() if not _is_source_jar(file)]

def _is_source_jar(file):
  return file.basename.endswith("-sources.jar")

# TODO: it seems this could be reworked to use java_common.merge
def _collect(deps):
  transitive_compile_jars = []
  runtime_jars = []
  compile_jars = []

  for dep_target in deps:
      java_provider = dep_target[JavaInfo]
      compile_jars.append(java_provider.compile_jars)
      transitive_compile_jars.append(java_provider.transitive_compile_time_jars)
      runtime_jars.append(java_provider.transitive_runtime_jars)

  return struct(transitive_runtime_jars = depset(transitive = runtime_jars),
                transitive_compile_jars = depset(transitive = transitive_compile_jars),
                compile_jars = depset(transitive = compile_jars))

def _collect_labels(deps, jars2labels):
  for dep_target in deps:
      java_provider = dep_target[JavaInfo]
      _transitively_accumulate_labels(dep_target, java_provider,jars2labels)

def _transitively_accumulate_labels(dep_target, java_provider, jars2labels):
  if hasattr(dep_target, "jars_to_labels"):
    jars2labels.update(dep_target.jars_to_labels)
  #scala_library doesn't add labels to the direct dependency itself
  for jar in java_provider.compile_jars.to_list():
    jars2labels[jar.path] = dep_target.label

def _collect_runtime(runtime_deps):
  jar_deps = []
  for dep_target in runtime_deps:
      java_provider = dep_target[JavaInfo]
      jar_deps.append(java_provider.transitive_runtime_jars)

  return depset(transitive = jar_deps)

scala_import = rule(
  implementation=_scala_import_impl,
  attrs={
      "jars": attr.label_list(allow_files=True), #current hidden assumption is that these point to full, not ijar'd jars
      "deps": attr.label_list(),
      "runtime_deps": attr.label_list(),
      "exports": attr.label_list()
      },
)
