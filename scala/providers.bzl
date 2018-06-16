# TODO: this should really be a bazel provider, but we are using old-style rule outputs
# we need to document better what the intellij dependencies on this code actually are
def create_scala_provider(ijar, class_jar, compile_jars,
                          transitive_runtime_jars, deploy_jar, full_jars,
                          statsfile):

  formatted_for_intellij = [
      struct(class_jar = jar, ijar = None, source_jar = None, source_jars = [])
      for jar in full_jars
  ]

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
      transitive_exports = []  #needed by intellij plugin
  )

ScalaWorker = provider(
    doc = "ScalaWorker",
    fields = ["scalac",
              "scalalib",
              "scalareflect",
              "scalacompiler",
              "scalatest",
              "scalatest_runner"])

def _declare_scala_worker(ctx):
  return [
      ScalaWorker(
          scalac = ctx.attr.scalac,
          scalalib = ctx.attr.scalalib,
          scalareflect = ctx.attr.scalareflect,
          scalacompiler = ctx.attr.scalacompiler,
          scalatest = ctx.attr.scalatest,
          scalatest_runner = ctx.attr.scalatest_runner,
      )
  ]

declare_scala_worker = rule(
    implementation = _declare_scala_worker,
    attrs = {
        "scalac": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//src/java/io/bazel/rulesscala/scalac"),
            allow_files = True),
        "scalalib": attr.label(
            default = Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library"
            ),
            allow_files = True),
        "scalareflect": attr.label(
            default = Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_reflect"
            ),
            allow_files = True),
        "scalacompiler": attr.label(
            default = Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_compiler"
            ),
            allow_files = True),
        "scalaxml": attr.label(
            default = Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_xml"
            ),
            allow_files = True),
        "scalatest": attr.label_list(
            default = [Label(
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest_2_11")],
            allow_files = True),
        "scalatest_runner": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//src/java/io/bazel/rulesscala/scala_test:runner_2_11.jar"),
            allow_files = True),
    })
