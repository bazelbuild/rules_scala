#!/usr/bin/env bash

set -euo pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"${dir}"/test_lint.sh
"${dir}"/test_rules_scala.sh
"${dir}"/test_version.sh
"${dir}"/test_cross_build.sh
"${dir}"/test_reproducibility.sh
#"${dir}"/test_intellij_aspect.sh
"${dir}"/test_examples.sh
"${dir}"/test_coverage.sh
"${dir}"/test_thirdparty_version.sh
"${dir}"/dt_patches/dt_patch_test.sh
