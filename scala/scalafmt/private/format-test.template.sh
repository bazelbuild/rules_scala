#!/bin/bash -e
RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
WORKSPACE_ROOT="${1:-$BUILD_WORKSPACE_DIRECTORY}"
NONDEFAULTPATH=(${RUNPATH//bin/ })
NONDEFAULTPATH="${NONDEFAULTPATH[0]}"bin

EXIT=0
while read original formatted; do
    if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
        if ! cmp -s "$WORKSPACE_ROOT/$original" "$NONDEFAULTPATH/$formatted"; then
            echo $original
            diff "$WORKSPACE_ROOT/$original" "$NONDEFAULTPATH/$formatted" || true
            EXIT=1
        fi
    fi
done < "$NONDEFAULTPATH"/%manifest%

exit $EXIT
