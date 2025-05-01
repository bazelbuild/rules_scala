#!/usr/bin/env bash
#
# Synchronizes .bazelversion in nested workspaces with the top level workspace.
#
# These could be symlinks, but that might break Windows users who don't know how
# to enable symlinks. Of course, they're programmers, they should learn, but
# avoiding surprises as a general principle is best.
#
# What would be ideal is the `import ../.bazelrc` syntax supported by Bazel, but
# Bazelisk doesn't currently support that.

ROOTDIR="${BASH_SOURCE[0]%/*}/.."
cd "$ROOTDIR"

if [[ "$?" -ne 0 ]]; then
  echo "Could not change to $ROOTDIR." >&2
  exit 1
elif [[ ! -r .bazelversion ]]; then
  echo ".bazelversion doesn't exist or isn't readable in $PWD." >&2
  exit 1
fi

while IFS="" read repo_marker_path; do
  repo_path="${repo_marker_path%/*}"

  # We search for WORKSPACE and MODULE.bazel instead of .bazelversion in case
  # anyone adds new child repositories. But we need to guard against overwriting
  # the top-level WORKSPACE and MODULE.bazel files.
  if [[ "$repo_path" != "$repo_marker_path" ]]; then
    cp .bazelversion "$repo_path"
  fi
done < <(find [A-Za-z0-9]* \( -name "WORKSPACE" -or -name "MODULE.bazel" \))
