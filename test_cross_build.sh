#!/usr/bin/env bash

set -e

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell

. "${test_dir}"/test_cross_build.sh
