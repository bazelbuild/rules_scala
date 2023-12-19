#!/usr/bin/env bash

set -eou pipefail

content="$(cat $1)"

function is_windows() {
  [[ "${OSTYPE}" =~ msys* ]] || [[ "${OSTYPE}" =~ cygwin* ]]
}

# Windows needs .exe suffix
if  is_windows; then
    binary_ext=".exe"
else
    binary_ext=""
fi

expected="test/ScalaBinary${binary_ext}"$'\ntest/ScalaBinary.jar'

if [ "$content" != "$expected" ]; then
    echo "Unexpected rootpaths: $content"
    echo "$expected"
    exit 1
fi
