#!/usr/bin/env bash
#
# Cleans the output base and shuts down the Bazel servers of nested repos.
#
# There shouldn't be a need to run this regularly. However, if disk space gets
# tight, this will clean all nested repos.

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

while IFS= read -r repo; do
  repo="${repo%/MODULE.bazel}"
  echo "cleaning: $repo"

  cd "$repo"
  bazel clean --expunge_async 2>/dev/null
  cd "$dir"
done < <(git ls-files '*/*MODULE.bazel')
