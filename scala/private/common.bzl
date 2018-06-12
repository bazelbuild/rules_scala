def write_manifest(ctx):
  # TODO(bazel-team): I don't think this classpath is what you want
  manifest = "Class-Path: \n"
  if getattr(ctx.attr, "main_class", ""):
    manifest += "Main-Class: %s\n" % ctx.attr.main_class

  ctx.actions.write(output = ctx.outputs.manifest, content = manifest)

def collect_srcjars(targets):
  srcjars = []
  for target in targets:
    if hasattr(target, "srcjars"):
      srcjars.append(target.srcjars.srcjar)
  return depset(srcjars)

def collect_jars(dep_targets, dependency_analyzer_is_off = True):
  """Compute the runtime and compile-time dependencies from the given targets"""  # noqa

  if dependency_analyzer_is_off:
    return _collect_jars_when_dependency_analyzer_is_off(dep_targets)
  else:
    return _collect_jars_when_dependency_analyzer_is_on(dep_targets)

def _collect_jars_when_dependency_analyzer_is_off(dep_targets):
  compile_jars = []
  runtime_jars = []

  for dep_target in dep_targets:
    if JavaInfo in dep_target:
      java_provider = dep_target[JavaInfo]
      compile_jars.append(java_provider.compile_jars)
      runtime_jars.append(java_provider.transitive_runtime_jars)
    else:
      # support http_file pointed at a jar. http_jar uses ijar,
      # which breaks scala macros
      compile_jars.append(filter_not_sources(dep_target.files))
      runtime_jars.append(filter_not_sources(dep_target.files))

  return struct(
      compile_jars = depset(transitive = compile_jars),
      transitive_runtime_jars = depset(transitive = runtime_jars),
      jars2labels = {},
      transitive_compile_jars = depset())

def _collect_jars_when_dependency_analyzer_is_on(dep_targets):
  transitive_compile_jars = []
  jars2labels = {}
  compile_jars = []
  runtime_jars = []

  for dep_target in dep_targets:
    current_dep_compile_jars = None
    current_dep_transitive_compile_jars = None

    if JavaInfo in dep_target:
      java_provider = dep_target[JavaInfo]
      current_dep_compile_jars = java_provider.compile_jars
      current_dep_transitive_compile_jars = java_provider.transitive_compile_time_jars
      runtime_jars.append(java_provider.transitive_runtime_jars)
    else:
      # support http_file pointed at a jar. http_jar uses ijar,
      # which breaks scala macros
      current_dep_compile_jars = filter_not_sources(dep_target.files)
      current_dep_transitive_compile_jars = filter_not_sources(dep_target.files)
      runtime_jars.append(filter_not_sources(dep_target.files))

    compile_jars.append(current_dep_compile_jars)
    transitive_compile_jars.append(current_dep_transitive_compile_jars)
    add_labels_of_jars_to(jars2labels, dep_target,
                          current_dep_transitive_compile_jars.to_list(),
                          current_dep_compile_jars.to_list())

  return struct(
      compile_jars = depset(transitive = compile_jars),
      transitive_runtime_jars = depset(transitive = runtime_jars),
      jars2labels = jars2labels,
      transitive_compile_jars = depset(transitive = transitive_compile_jars))

# When import mavan_jar's for scala macros we have to use the jar:file requirement
# since bazel 0.6.0 this brings in the source jar too
# the scala compiler thinks a source jar can look like a package space
# causing a conflict between objects and packages warning
#  error: package cats contains object and package with same name: implicits
# one of them needs to be removed from classpath
# import cats.implicits._

def not_sources_jar(name):
  return "-sources.jar" not in name

def filter_not_sources(deps):
  return depset(
      [dep for dep in deps.to_list() if not_sources_jar(dep.basename)])

def add_labels_of_jars_to(jars2labels, dependency, all_jars, direct_jars):
  for jar in direct_jars:
    _add_label_of_direct_jar_to(jars2labels, dependency, jar)
  for jar in all_jars:
    _add_label_of_indirect_jar_to(jars2labels, dependency, jar)

def _add_label_of_direct_jar_to(jars2labels, dependency, jar):
  jars2labels[jar.path] = dependency.label

def _add_label_of_indirect_jar_to(jars2labels, dependency, jar):
  if _label_already_exists(jars2labels, jar):
    return

  # skylark exposes only labels of direct dependencies.
  # to get labels of indirect dependencies we collect them from the providers transitively
  if _provider_of_dependency_contains_label_of(dependency, jar):
    jars2labels[jar.path] = dependency.jars_to_labels[jar.path]
  else:
    jars2labels[
        jar.
        path] = "Unknown label of file {jar_path} which came from {dependency_label}".format(
            jar_path = jar.path, dependency_label = dependency.label)

def _label_already_exists(jars2labels, jar):
  return jar.path in jars2labels

def _provider_of_dependency_contains_label_of(dependency, jar):
  return hasattr(dependency,
                 "jars_to_labels") and jar.path in dependency.jars_to_labels

# TODO this seems to have limited value now that JavaInfo has everything
def create_java_provider(scalaattr, transitive_compile_time_jars):
  return java_common.create_provider(
      use_ijar = False,
      compile_time_jars = scalaattr.compile_jars,
      runtime_jars = scalaattr.transitive_runtime_jars,
      transitive_compile_time_jars = depset(
          transitive = [transitive_compile_time_jars, scalaattr.compile_jars]),
      transitive_runtime_jars = scalaattr.transitive_runtime_jars,
  )
