#!/bin/bash -e

# Explanation: IF $BUILD_WORKSPACE_DIRECTORY is set to something (as it would be during a
# `bazel run`), then append a trailing `/`.  If it's not set (as it wouldn't be during
# a `bazel test` invocation in a wrapping `sh_test` rule), then elide the trailing `/`, and
# instead rely upon a relative path from the test's runtrees.  The corresponding change
# to `phase_scalafmt` places the source files into the `runfiles` set, so they'll be symlinked
# correctly in the appropriate relative location.
WORKSPACE_ROOT="${1:-${BUILD_WORKSPACE_DIRECTORY}${BUILD_WORKSPACE_DIRECTORY:+/}}"

RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
RUNPATH=(${RUNPATH//bin/ })
RUNPATH="${RUNPATH[0]}"bin

EXIT=0

while read original formatted; do
    if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
        if ! cmp -s "${WORKSPACE_ROOT}$original" "$RUNPATH/$formatted"; then
            echo $original
            diff "${WORKSPACE_ROOT}$original" "$RUNPATH/$formatted" || true
            EXIT=1
        fi
    fi
done < "$RUNPATH"/%manifest%

exit $EXIT
