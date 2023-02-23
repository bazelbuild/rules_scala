#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
PREFIX="rules_scala-${TAG:1}"
ARCHIVE="rules_scala-$TAG.tar.gz"
SHA=$(git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip | shasum -a 256 | awk '{print $1}')

cat << EOF
## Using WORKSPACE

Paste this snippet into your \`WORKSPACE\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/${TAG}/${ARCHIVE}",
)
\`\`\`

See https://github.com/bazelbuild/rules_scala#getting-started for full setup instructions.
EOF
