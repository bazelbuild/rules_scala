#!/bin/bash -e
RUNPATH="${TEST_SRCDIR-$0.runfiles}"/%workspace%
WORKSPACE_ROOT="${1:-$BUILD_WORKSPACE_DIRECTORY}"

if [ -f "$RUNPATH"/%manifest% ]; then
    while read original formatted; do
        if [[ ! -z "$original" ]] && [[ ! -z "$formatted" ]]; then
            if ! cmp -s "$RUNPATH/$original" "$RUNPATH/$formatted"; then
                if [ -z "$WORKSPACE_ROOT" ]; then
                    echo "$original"
                    diff "$RUNPATH/$original" "$RUNPATH/$formatted" || true
                    EXIT=1
                else
                    echo "Formatting $original"
                    cp "$RUNPATH/$formatted" "$WORKSPACE_ROOT/$original"
                fi
            fi
        fi
    done < "$RUNPATH"/%manifest%
else
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
fi

exit $EXIT
