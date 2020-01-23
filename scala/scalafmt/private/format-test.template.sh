#!/bin/bash -e
WORKSPACE_ROOT="${1:-$BUILD_WORKSPACE_DIRECTORY}"
RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
RUNPATH=(${RUNPATH//bin/ })
RUNPATH="${RUNPATH[0]}"bin

EXIT=0
while read original formatted; do
    if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
        if ! cmp -s "$WORKSPACE_ROOT/$original" "$RUNPATH/$formatted"; then
            echo $original
            diff "$WORKSPACE_ROOT/$original" "$RUNPATH/$formatted" || true
            EXIT=1
        fi
    fi
done < "$RUNPATH"/%manifest%

exit $EXIT
