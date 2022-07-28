#!/usr/bin/env bash

set -eou pipefail

content="$(cat $1)"
expected=$'test/ScalaBinary.jar\ntest/ScalaBinary.sh'
if [ "$content" != "$expected" ]; then
    echo "Unexpected rootpaths: $content"
    echo "Expected rootpaths: $expected"
    exit 1
fi
