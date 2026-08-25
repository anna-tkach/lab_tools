#!/bin/bash
# _tools/utils_paths_computing.sh
#
# Файл не запускається сам по собі — інші скрипти підключають його через "source".

# Builds absolute path for repo for branch in lab directory.
# Input params:
#   lab_absolute_path - abs path to [lab] directory.
#   branch_name - can be one from [repo, vault, runner].
#   object_subpath - can be one from [owner_subpath, project_subpath, repo_subpath]
compute_lab_branch_absolute_path() {
  # 1. Read input parameters
  local lab_absolute_path="$1"
  local branch_name="$2"
  local object_subpath="$3"

  # 2. Make sure all input params are passed
  if [ -z "$lab_absolute_path" ] || [ -z "$branch_name" ] || [ -z "$object_subpath" ]; then
    echo "Використання: compute_lab_branch_absolute_path() <lab_absolute_path> <branch_name> <object_subpath>">&2
    return 1
  fi

  # 3. Build abs path
  local abs_path="$lab_absolute_path/$branch_name/$object_subpath"
  echo "$abs_path"
}