#!/usr/bin/env bash

echo "Executing: " $@
#limiting the classpath to simulate a large classpath which is over the OS limit
export CLASSPATH_LIMIT=10
$@
