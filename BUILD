repo = ["WORKSPACE",
         ".bazelrc",
         "//scala:sources",
         "//scala/support:sources",
         "//src/java/com/google/devtools/build/lib:sources",
         "//src/java/io/bazel/rulesscala/io_utils:sources",
         "//src/java/io/bazel/rulesscala/jar:sources",
         "//src/java/io/bazel/rulesscala/scalac:sources",
         "//src/java/io/bazel/rulesscala/worker:sources",
         "//src/scala:sources",
         "//src/scala/io/bazel/rules_scala/scrooge_support:sources",
         "//src/scala/io/bazel/rules_scala/tut_support:sources",
         "//src/scala/scripts:sources",
         "//test:sources",
         "//test/data:sources",
         "//test/src/main/resources/scala/test:sources",
         "//test/src/main/scala/scala/test/srcjars:sources",
         "//test/src/main/scala/scala/test/twitter_scrooge:sources",
         "//test/src/main/scala/scala/test/twitter_scrooge/thrift:sources",
         "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:sources",
         "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift3:sources",
         "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift4:sources",
         "//test/tut:sources",
         "//test_expect_failure/disappearing_class:sources",
         "//test_expect_failure/scala_library_suite:sources",
         "//test_expect_failure/transitive/java_to_scala:sources",
         "//test_expect_failure/transitive/scala_to_java:sources",
         "//test_expect_failure/transitive/scala_to_scala:sources",
         "//thrift:sources",
         "//tut_rule:sources",
         "//twitter_scrooge:sources"]

sh_test(
    name = "build_targets_under_tests_package",
    size = "large",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","build","test/..."])

sh_test(
    name = "run_tests_under_tests_package",
    size = "large",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","test","test/..."] )
    
sh_test(
    name = "run_justscrooges",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","run","test/src/main/scala/scala/test/twitter_scrooge:justscrooges"] )
    
sh_test(
    name = "run_JavaBinary",
    size = "large",
    data = repo + ["@local_jdk//:jdk"],
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:JavaBinary"] )

sh_test(
    name = "run_JavaBinary2",
    size = "large",
    data = repo + ["@local_jdk//:jdk"],
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:JavaBinary2"] )
    
sh_test(
    name = "MixJavaScalaLibBinary",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:MixJavaScalaLibBinary"] )
    
sh_test(
    name = "run_ScalaBinary",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:ScalaBinary"] )
    
    
sh_test(
    name = "test_disappearing_class",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["test_disappearing_class"] )
    
    
sh_test(
    name = "run_ScalaLibBinary",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:ScalaLibBinary"] )  
      
sh_test(
    name = "JavaOnlySources",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["bazel","run","test:JavaOnlySources"] )
    
    
sh_test(
    name = "test_build_is_identical",
    size = "large",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["test_build_is_identical"] )
    
    
sh_test(
    name = "test_transitive_deps",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["test_transitive_deps"] )
    
    
sh_test(
    name = "test_scala_library_suite",
    size = "medium",
    data = repo,
    srcs = ["test_run.sh"],
    args = ["test_scala_library_suite"] )
    

    
