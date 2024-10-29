#!/usr/bin/env bash
#
# Updates .bazelrc files to enable or disable WORKSPACE builds.
#
# This is for testing `WORKSPACE` and Bzlmod compatibility. The produced changes
# should never be checked in. Run this script with the `restore` argument to
# revert them before committing.

ROOTDIR="${BASH_SOURCE[0]%/*}/.."
cd "$ROOTDIR"

if [[ "$?" -ne 0 ]]; then
  echo "Could not change to $ROOTDIR." >&2
  exit 1
fi

usage() {
  local lines=()
  while IFS='' read line; do
    if [[ "${line:0:1}" != '#' ]]; then
      printf '%s\n' "Usage: $0 [ on | off | restore ]" "${lines[@]:1}" >&2
      exit "$1"
    fi
    lines+=("${line:2}")
  done <$0
}

update_bazelrc_files() {
  local mode="$1"
  local workspace_options="build --noenable_bzlmod"
  local bzlmod_options="build --enable_bzlmod"
  local bazel_version="$(bazel --version 2>&1)"

  if [[ "$?" -ne 0 ]]; then
    echo "failed to run `bazel --version`: $bazel_version" >&2
    exit 1
  elif [[ "${bazel_version#* }" =~ ^(7|8)\. ]]; then
    workspace_options="${workspace_options} --enable_workspace"
    bzlmod_options="${bzlmod_options} --noenable_workspace"
  fi

  local enabled_options="$workspace_options"
  local disabled_options="$bzlmod_options"

  if [[ "$mode" == "off" ]]; then
    enabled_options="$bzlmod_options"
    disabled_options="$workspace_options"
  fi

  already_enabled="($enabled_options|import [./]*/.bazelrc)"

  # Searches for WORKSPACE instead of .bazelrc because not all repos may have a
  # .bazelrc file.
  while IFS='' read repo_marker_path; do
    local repo_path="${repo_marker_path%/*}"
    local bazelrc_path="$repo_path/.bazelrc"

    # The top level repo is a special case.
    if [[ "$repo_path" == "$repo_marker_path" ]]; then
      bazelrc_path="./.bazelrc"
    fi

    if [[ ! -f "$bazelrc_path" ]]; then
      echo "$enabled_options" > "$bazelrc_path"
      continue
    fi

    content="$(< "$bazelrc_path")"

    if [[ "$content" =~ $disabled_options ]]; then
      echo "${content//$disabled_options/$enabled_options}" >"$bazelrc_path"
    elif [[ ! "$content" =~ $already_enabled ]]; then
      echo "$enabled_options" >> "$bazelrc_path"
    fi

  done < <(find [A-Za-z0-9]* -name "WORKSPACE")
}

restore_bazelrc_files() {
  local staged=()
  local unstaged=()
  local untracked=()

  get_bazelrc_files_by_status

  if [[ "${#staged[@]}" -ne 0 ]]; then
    # Staged files can be untracked after unstaging, so recalculate.
    git restore --staged "${staged[@]}"
    unstaged=()
    untracked=()
    get_bazelrc_files_by_status
  fi

  if [[ "${#unstaged[@]}" -ne 0 ]]; then
    git restore "${unstaged[@]}"
  fi

  if [[ "${#untracked[@]}" -ne 0 ]]; then
    git clean -f "${untracked[@]}"
  fi
}

get_bazelrc_files_by_status() {
  while IFS='' read status_line; do
    local status_code="${status_line:0:1}"
    local bazelrc_file="${status_line:3}"

    if [[ "$status_code" == '?' ]]; then
      untracked+=("$bazelrc_file")
    elif [[ "$status_code" == ' ' ]]; then
      unstaged+=("$bazelrc_file")
    else
      staged+=("$bazelrc_file")
    fi
  done < <(git status -s '.bazelrc' '**/.bazelrc')
}

if [[ "$#" -ne 1 ]]; then
  usage 1
fi

case "$1" in
  on|off)
    update_bazelrc_files "$1"
    ;;
  restore)
    restore_bazelrc_files
    ;;
  *)
    usage 1
    ;;
esac
