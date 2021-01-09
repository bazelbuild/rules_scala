#!/usr/bin/env bash
#
# Script to build custom version of `JacocoCoverage_jarjar_deploy.jar` from Jacoco and Bazel repositories.
#
# The default `JacocoCoverage_jarjar_deploy.jar` has some issues:
#
# 1. Bazel uses Jacoco 0.8.3 that has poor Scala support, including a bug that filters out Scala lambdas on Scala >=2.12
#
#    Bug report:
#    https://github.com/bazelbuild/rules_scala/issues/1056
#    https://github.com/bazelbuild/bazel/issues/11674
#
#    Backported fix from Jacoco 0.8.5 to Jacoco 0.8.3:
#    https://github.com/gergelyfabian/jacoco/tree/0.8.3-scala-lambda-fix
#
# 2. Bazel ignores Jacoco's filtering for branch coverage metrics:
#
#    Bug report:
#    https://github.com/bazelbuild/bazel/issues/12696
#
#    Proposed fix:
#    https://github.com/gergelyfabian/bazel/tree/branch_coverage_respect_jacoco_filtering
#
# 3. Scala support on newer Jacoco versions (including 0.8.5) is still lacking some functionality
#
#    E.g. a lot of generated methods for case classes, lazy vals or other Scala features are causing falsely missed branches in branch coverage.
#
#    Proposed changes in:
#    https://github.com/gergelyfabian/jacoco/tree/scala
#
#    Backported to 0.8.3 (to be usable with current Bazel):
#    https://github.com/gergelyfabian/jacoco/tree/0.8.3-scala
#
#    These branches also include the Scala 2.12 lambda coverage fix.
#
# You can use this script to build a custom version of `JacocoCoverage_jarjar_deploy.jar`, including any fixes from the above list you wish
# and then provide the built jar as a parameter of `java_toolchain` and/or `scala_toolchain` to use the changed behavior for coverage.
#
# Choose the fixes from the above list by configuring the used branches for Bazel and Jacoco repos below.

set -e

source_path=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

build_dir=/tmp/bazel_jacocorunner_build

mkdir -p $build_dir

jacoco_repo=$build_dir/jacoco
# Take a fork for Jacoco that contains Scala fixes.
jacoco_remote=https://github.com/gergelyfabian/jacoco
# Choose a branch you'd like to use.
# Default option, take only fixes for Scala 2.12 lambdas backported to Jacoco 0.8.3:
jacoco_branch=0.8.3-scala-lambda-fix
# Advanced option, take further fixes for Scala (2.11, 2.12 and 2.13) - branch in development:
#jacoco_branch=0.8.3-scala

# Choose the patches that you'd like to use:
jacoco_patches=""
# Bazel needs to have a certain Jacoco package version:
jacoco_patches="$jacoco_patches 0001-Build-Jacoco-for-Bazel.patch"
# Uncomment this if you are behind a proxy:
#jacoco_patches="$jacoco_patches 0002-Build-Jacoco-behind-proxy.patch"


# Jacoco version should be 0.8.3 in any case as Bazel is only compatible with that at this moment.
jacoco_version=0.8.3

bazel_repo=$build_dir/bazel
bazel_remote=https://github.com/bazelbuild/bazel
bazel_branch=master
# Advanced option: take a fork that has fixes for Jacoco LCOV formatter, to respect Jacoco filtering
# (fixes for Scala in Jacoco respected in Bazel branch coverage):
#bazel_remote=https://github.com/gergelyfabian/bazel
#bazel_branch=branch_coverage_respect_jacoco_filtering

bazel_build_target=JacocoCoverage_jarjar_deploy.jar

destination_dir=$build_dir

# Generate the jar.

if [ ! -d $jacoco_repo ]; then
  (
  cd $(dirname $jacoco_repo)
  git clone $jacoco_remote
  )
fi

if [ ! -d $bazel_repo ]; then
  (
  cd $(dirname $bazel_repo)
  git clone $bazel_remote
  )
fi

(
cd $jacoco_repo
git remote update
git checkout origin/$jacoco_branch
# Need to patch Jacoco:
for patch in $jacoco_patches; do
  git am $source_path/$patch
done
mvn clean install
)

(
cd $bazel_repo
git remote update
git checkout origin/$bazel_branch

# Prepare Jacoco version.
cd third_party/java/jacoco
# Remove any previously unpacked Jacoco files.
rm -rf coverage/ doc/ index.html lib/ test/
unzip $HOME/.m2/repository/org/jacoco/jacoco/${jacoco_version}/jacoco-${jacoco_version}.zip
cp lib/jacocoagent.jar jacocoagent-${jacoco_version}.jar
cp lib/org.jacoco.agent-* org.jacoco.agent-${jacoco_version}.jar
cp lib/org.jacoco.core-* org.jacoco.core-${jacoco_version}.jar
cp lib/org.jacoco.report-* org.jacoco.report-${jacoco_version}.jar
cd ../../..

# Build JacocoRunner.
bazel build src/java_tools/junitrunner/java/com/google/testing/coverage:$bazel_build_target
cp bazel-bin/src/java_tools/junitrunner/java/com/google/testing/coverage/$bazel_build_target $destination_dir/
# Make the jar writable to enable re-running the script.
chmod +w $destination_dir/$bazel_build_target

echo "JacocoRunner is available at: $destination_dir/$bazel_build_target"
)
