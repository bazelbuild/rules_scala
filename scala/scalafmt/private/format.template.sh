#!/bin/bash -e
RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
WORKSPACE_ROOT="${1:-$BUILD_WORKSPACE_DIRECTORY}"
NONDEFAULTPATH=(${RUNPATH//bin/ })
NONDEFAULTPATH="${NONDEFAULTPATH[0]}"bin

while read original formatted; do
    if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
        if ! cmp -s "$WORKSPACE_ROOT/$original" "$NONDEFAULTPATH/$formatted"; then
            echo "Formatting $original"
            cp "$NONDEFAULTPATH/$formatted" "$WORKSPACE_ROOT/$original"
        fi
    fi
done < "$NONDEFAULTPATH"/%manifest%
