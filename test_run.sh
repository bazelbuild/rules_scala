#!/bin/bash

set -e

test_disappearing_class() {
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  bazel build test_expect_failure/disappearing_class:uses_class
  echo -e "package scala.test\n\nobject BackgroundNoise{}" > test_expect_failure/disappearing_class/ClassProvider.scala
  set +e
  bazel build test_expect_failure/disappearing_class:uses_class
  RET=$?
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  if [ $RET -eq 0 ]; then
    echo "Class caching at play. This should fail"
    exit 1
  fi
  set -e
}

test_build_is_identical() {
  bazel build test/...
  md5sum bazel-bin/test/*.jar > hash1
  bazel clean
  bazel build test/...
  md5sum bazel-bin/test/*.jar > hash2
  diff hash1 hash2
}

test_transitive_deps() {
  set +e

  bazel build test_expect_failure/transitive/scala_to_scala:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/transitive/scala_to_scala:d' should have failed."
    exit 1
  fi

  bazel build test_expect_failure/transitive/java_to_scala:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/transitive/java_to_scala:d' should have failed."
    exit 1
  fi

  bazel build test_expect_failure/transitive/scala_to_java:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_transitive_deps/scala_to_java:d' should have failed."
    exit 1
  fi

  set -e
  exit 0
}

test_repl() {
  echo "import scala.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl | grep "foo scala" &&
  echo "import scala.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl | grep "bar" &&
  echo "import scala.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl | grep "A hui hou"
}

bazel build test/... \
  && bazel run test:ScalaBinary \
  && bazel run test:ScalaLibBinary \
  && bazel run test:JavaBinary \
  && bazel run test:JavaBinary2 \
  && bazel run test:MixJavaScalaLibBinary \
  && bazel run test/src/main/scala/scala/test/twitter_scrooge:justscrooges \
  && bazel test test/... \
  && find -L ./bazel-testlogs -iname "*.xml" \
  && (find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null) \
  && test_disappearing_class \
  && test_build_is_identical \
  && test_transitive_deps \
  && test_repl \
  && echo "all good"
