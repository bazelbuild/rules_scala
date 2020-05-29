#!/bin/bash -e
WORKSPACE_ROOT="${1:-$BUILD_WORKSPACE_DIRECTORY}"
RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
RUNPATH=(${RUNPATH//bin/ })
RUNPATH="${RUNPATH[0]}"bin

while read original formatted; do
    if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
        if ! cmp -s "$WORKSPACE_ROOT/$original" "$RUNPATH/$formatted"; then
            echo "Formatting $original"
            cp "$RUNPATH/$formatted" "$WORKSPACE_ROOT/$original"
        fi
    fi
done < "$RUNPATH"/%manifest%
