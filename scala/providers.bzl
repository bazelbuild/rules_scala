# TODO: this should really be a bazel provider, but we are using old-style rule outputs
# we need to document better what the intellij dependencies on this code actually are
def create_scala_provider(
        ijar,
        class_jar,
        compile_jars,
        transitive_runtime_jars,
        deploy_jar,
        full_jars,
        statsfile):

    formatted_for_intellij = [struct(
        class_jar = jar,
        ijar = None,
        source_jar = None,
        source_jars = []) for jar in full_jars]

    rule_outputs = struct(
        ijar = ijar,
        class_jar = class_jar,
        deploy_jar = deploy_jar,
        jars = formatted_for_intellij,
        statsfile = statsfile,
    )
    # Note that, internally, rules only care about compile_jars and transitive_runtime_jars
    # in a similar manner as the java_library and JavaProvider
    return struct(
        outputs = rule_outputs,
        compile_jars = compile_jars,
        transitive_runtime_jars = transitive_runtime_jars,
        transitive_exports = [] #needed by intellij plugin
    )


ScalaWorker = provider(
    doc = "ScalaWorker",
    fields = [
        "scalac",
        "scalalib"
    ]
)

def _declare_scala_worker(ctx):
    return [ScalaWorker(
        scalac = ctx.attr.scalac,
        scalalib = ctx.attr.scalalib
    )]

declare_scala_worker = rule(
    implementation = _declare_scala_worker,
    attrs = {
        "scalac": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/scalac"), allow_files=True),
        "scalalib": attr.label(default=Label("@scala_2_12//:scala-library"), allow_files=True),
    }
)
