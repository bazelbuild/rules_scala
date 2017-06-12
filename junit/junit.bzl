def _bazel_test_runner_repositories():
  native.maven_jar(
        name = "io_bazel_rules_scala_javax_javax_inject",
        artifact = "javax.inject:javax.inject:1"
        )
  native.bind(name = 'io_bazel_rules_scala/dependency/javax/javax_inject', actual = '@io_bazel_rules_scala_javax_javax_inject//jar')

  native.maven_jar(
        name = "io_bazel_rules_scala_javax_annotation_inject_jsr305",
        artifact = "com.google.code.findbugs:jsr305:3.0.2"
        )
  native.bind(name = 'io_bazel_rules_scala/dependency/javax_annotation_inject/jsr305', actual = '@io_bazel_rules_scala_javax_annotation_inject_jsr305//jar')


def junit_repositories():
  native.maven_jar(
      name = "io_bazel_rules_scala_junit_junit",
      artifact = "junit:junit:4.12",
      sha1 = "2973d150c0dc1fefe998f834810d68f278ea58ec",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/junit/junit', actual = '@io_bazel_rules_scala_junit_junit//jar')
  
  native.maven_jar(
      name = "io_bazel_rules_scala_org_hamcrest_hamcrest_core",
      artifact = "org.hamcrest:hamcrest-core:1.3",
      sha1 = "42a25dc3219429f0e5d060061f71acb49bf010a0",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/hamcrest/hamcrest_core', actual = '@io_bazel_rules_scala_org_hamcrest_hamcrest_core//jar')

  _bazel_test_runner_repositories()