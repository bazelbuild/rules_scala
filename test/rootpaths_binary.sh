#!/usr/bin/env bash

set -eou pipefail

content="$(cat $1)"
expected=$'test/ScalaBinary\ntest/ScalaBinary.jar'
if [ "$content" != "$expected" ]; then
    echo "Unexpected rootpaths: $content"
    echo "$expected"
    exit 1
fi
