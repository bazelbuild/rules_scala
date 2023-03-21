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
#    Backported fix from Jacoco 0.8.5 to Jacoco 0.8.3 (current Bazel is not compatible with Jacoco 0.8.5):
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
#
# Patches:
#
# There are also some patches that may need to be applied for Jacoco, according to your preferences:
#
# 1. Bazel is compatible only with Jacoco in a specific package name. This is not Jacoco-specific, so not committed to the Jacoco fork.
#    See 0001-Build-Jacoco-for-Bazel.patch.
# 2. Building Jacoco behind a proxy needs a workaround.
#    See 0002-Build-Jacoco-behind-proxy.patch.
#
# Set up the patch file names in `jacoco_patches`.
#
# Dependencies:
#
# On OS X greadlink is needed (by running `brew install coreutils`).

set -e



if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  readlink_cmd="readlink"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  readlink_cmd="greadlink"
else
  echo "OS not supported: $OSTYPE"
  exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 \
                                  | cut -d'"' -f2 \
                                  | sed 's/^1\.//' \
                                  | cut -d'.' -f1)

if [ "$JAVA_VERSION" != "8" ]; then
  echo "Unexpected java version: $JAVA_VERSION"
  echo "Please ensure this script is run with Java 8"
  exit 1
fi

source_path=$($readlink_cmd -f $(dirname ${BASH_SOURCE[0]}))

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
bazel_tag=4.1.0

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
git checkout tags/$bazel_tag

# Advanced option - check out a branch instead of the release tag
# git checkout origin/$bazel_branch

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
