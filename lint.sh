#!/bin/bash
# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eou pipefail

# Usage
# =====
#
# - to lint/check conformance to style and best practice of all the files in
# the current working directory: "./lint.sh" or "./lint.sh check".
# - to fix what can be fixed automatically: "./lint.sh fix".
# - to skip a step, e.g. Skylark linting: "FMT_SKYLINT=false ./lint.sh check".
#
#
# Linters/formatters featured here
# ================================
#
# - google-java-format: Java code
# - buildifier: BUILD/WORKSPACE files
# - skylint: Skylark files (*.bzl) - check only
# - yapf: Skylark and Python files
#
#
# An important note concerning trailing commas
# ============================================
#
# Yapf could generate during fixing this Skylark one-liner:
# ```
# foo = rule(attrs = {"hello": attr.string()}, implementation = _impl)
# ```
# from some perfectly normal-looking code:
# ```
# foo = rule(
#     implementation = _impl,
#     attrs = {
#         "hello": attr.string()
#     }
# )
# ```
# but this reformatting is not expected to pass validation.  What is missing
# is trailing commas, after the last argument to `rule` and after the last
# element of the dictionary.  If those are put:
# ```
# foo = rule(
#     implementation = _impl,
#     attrs = {
#         "hello": attr.string(),
#     },
# )
# ```
# then our configuration of Yapf won't touch anything.
#
#
# Implementation details: Why we need Buildifier, Skylint and Yapf
# ================================================================
#
# Why do we need Buildifier, Skylint and Yapf to validate Bazel/Skylark files?
# Skylark is after all only a dialect of Python!  The reasons are as follows:
#
# - Buildifier can fix BUILD/WORKSPACE files but breaks *.bzl files when it attempts
# to fix them.
#
# - Yapf is the only utility used here that can fix *.bzl files because it understands Python
# fully and not only a special subset of it.
#
# - However, Yapf does not enforce certain conventions that people have in *.bzl files,
# related to the fact that they are used to enrich BUILD files.  That's where
# Buildifier comes in handy.  For instance, Yapf could generate this one-liner:
# ```
# foo = rule(implementation = _impl, attrs = {"hello": attr.string()})
# ```
# but this is an error for Buildifier, as it expects every keyword argument
# to be on their own line as well as the attribute dictionary to be split, and the
# `attrs` argument to come before the `implementation` argument (alphabetical order).
# By running Buildifier after Yapf, we ensure that these conventions are respected.
# Here, to force Yapf to split the arguments and the dictionary, we can add a comma after
# the last argument/element.  Moreover, Yapf does not reorder keywords.  Overall,
# if we supply this snippet to Yapf:
# ```
# foo = rule(attrs = {"hello": attr.string(),}, implementation = _impl,)
# ```
# we'll end up, after fixing, with:
# ```
# foo = rule(
#     attrs = {
#         "hello": attr.string(),
#     },
#     implementation = _impl,
# )
# ```
# which passes the Buildifier validation.
#
# - Buildifier only validates *.bzl files with respect to their likeness to BUILD files.
# To validate the semantic specific to Skylark files and ensure good practices are followed
# (documentation, unused imports, ...), Skylint can be used.  Skylint only operates in "check"
# mode, it cannot fix anything on its own.  (On an unrelated note, Pylint gives meaningless
# results when applied to Skylark files, so that's why Skylint is used here.)
#
# - Overall, this sauce has been chosen because it gives an automatic formatting and
# linting warnings that feel natural for Skylark.

BASE="$(pwd)"
MODE="${1:-check}"

if [ "$MODE" = "check" ]; then
  JAVA_OPTIONS=--dry-run
  BUILDIFIER_MODE=check
  YAPF_OPTIONS=--diff
else
  YAPF_OPTIONS=--in-place
  JAVA_OPTIONS=--replace
  BUILDIFIER_MODE=fix
fi

BAZEL_BIN=$(bazel info bazel-bin)
BAZEL_OUTPUT_BASE=$(bazel info output_base)

function build() {
  # NOTE: if and when the Skylink target becomes public, use a sh_binary instead
  # of building everything here?
  bazel build --color=yes --show_progress_rate_limit=30 \
    @io_bazel//src/tools/skylark/java/com/google/devtools/skylark/skylint:Skylint \
    //private:java_format \
    @com_github_google_yapf//:yapf \
    @io_bazel_buildifier_linux//file \
    @io_bazel_buildifier_darwin//file
}

function format_py_like() {
  local PATTERN=$1
  local STYLE=$(cat)
  local OUTPUT

  OUTPUT=$(find "$BASE" \
                -not \( -path $BASE/.git -prune \) \
                -name "$PATTERN" -exec "$BAZEL_BIN/external/com_github_google_yapf/yapf/yapf" \
                $YAPF_OPTIONS \
                "--style=$STYLE" \
                {} \;)
  if [ $? != 0 ]; then
    return 1
  fi
  if [ "$MODE" = "check" ] && [ ! -z "$OUTPUT" ]; then
    echo "$OUTPUT"
    return 1
  fi
}

function format_skylark() {
  format_py_like "*.bzl" <<'EOF'
{
  based_on_style: google,
  spaces_around_default_or_named_assign: True,
  blank_lines_around_top_level_definition: 1,
  indent_width: 2,
  allow_split_before_dict_value: False,
  each_dict_entry_on_separate_line: True,
  split_arguments_when_comma_terminated: True,
}
EOF
}

function format_python() {
  format_py_like "*.py" <<'EOF'
{
  based_on_style: google,
  spaces_around_default_or_named_assign: True,
  blank_lines_around_top_level_definition: 2,
  indent_width: 2,
  indent_dictionary_value: True
}
EOF
}

function format_bazel() {
  if [ "$(uname)" = "Darwin" ]; then
    BUILDIFIER=$BAZEL_OUTPUT_BASE/external/io_bazel_buildifier_darwin/file/downloaded
  else
    BUILDIFIER=$BAZEL_OUTPUT_BASE/external/io_bazel_buildifier_linux/file/downloaded
  fi

  ERRORS=0
  $BUILDIFIER -mode=$BUILDIFIER_MODE $(
      find "$BASE" \
           -not \( -path $BASE/.git -prune \) \
           -name BUILD -type f)
  ERRORS=$((ERRORS+$?))
  $BUILDIFIER -mode=$BUILDIFIER_MODE $(
      find "$BASE" \
           -not \( -path $BASE/.git -prune \) \
           -name WORKSPACE -type f)
  ERRORS=$((ERRORS+$?))

  # (buildifier cannot format *.bzl files)
  if [ "$MODE" = "check" ] && ! $BUILDIFIER -mode=check $(find "$BASE" -not \( -path $BASE/.git -prune \) -name "*.bzl" -type f) >/dev/null; then
    echo "*.bzl BUILDIFIER ERRORS:"
    for f in $(find "$BASE" -not \( -path $BASE/.git -prune \) -name "*.bzl" -type f); do
      OUTPUT=$($BUILDIFIER -mode=diff $f)
      if [ ! -z "$OUTPUT" ]; then
        echo "$f"
        echo "$OUTPUT"
      fi
    done
    # Some errors are false positives.
    echo "(buildifier on *.bzl files: not enforced)"
  fi

  if [ $ERRORS != 0 ]; then
    echo "Errors: $ERRORS"
    return 1
  fi
}

function format_java() {
  local OUTPUT

  OUTPUT=$("$BAZEL_BIN/private/java_format" $JAVA_OPTIONS $(
               find "$BASE" \
                    -not \( -path $BASE/.git -prune \) \
                    -name "*.java" -type f))

  if [ "$MODE" = "check" ] && [ ! -z "$OUTPUT" ]; then
    echo "$OUTPUT"
    return 1
  fi
}

# Skylint only operates in "check" mode, it is a no-op in "fix" mode.
function skylint() {
  local OUTPUT

  OUTPUT=$(
      find "$BASE" \
           -not \( -path $BASE/.git -prune \) \
           -type f -name "*.bzl" -exec \
           "$BAZEL_BIN/external/io_bazel/src/tools/skylark/java/com/google/devtools/skylark/skylint/Skylint" \
           {} \;
        )
  if [ "$MODE" = "check" ] && [ ! -z "$OUTPUT" ]; then
    echo "$OUTPUT"
    return 1
  fi
}

SUMMARY=""
OVERALL_RESULT=0

function record() {
  local SECTION_NAME=$1
  local FUNC=$2
  local DO=$3
  local STATUS

  if ! $DO; then
    STATUS="Skipped"
  elif eval "$FUNC"; then
    STATUS="Ok"
  else
    STATUS="Failure"
    OVERALL_RESULT=1
  fi

  SUMMARY+="$SECTION_NAME    $STATUS"$'\n'
}

function summarize() {
  echo "============ SUMMARY ============"
  echo "$SUMMARY"
  return $OVERALL_RESULT
}

if "${FMT_PREPARE:-true}"; then
  build
fi
record skylark format_skylark "${FMT_SKYLARK:-true}"
record python format_python "${FMT_PYTHON:-true}"
record bazel format_bazel "${FMT_BAZEL:-true}"
record java format_java "${FMT_JAVA:-true}"
SKYLINT="${FMT_SKYLINT:-true}" && [ "$MODE" = "check" ]
record skylint skylint "$SKYLINT"
summarize
