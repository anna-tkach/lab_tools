#!/bin/bash
# _tools/utils_paths_computing.sh
#
# Файл не запускається сам по собі — інші скрипти підключають його через "source".

# Builds absolute path for [owner] for branch in lab directory.
# Input params:
#   lab_absolute_path - abs path to [lab] directory.
#   owner_subpath - like /own/ or /clients/client-1/ etc.
#   branch_name - can be one from [repo, vault, runner].
compute_lab_owner_branch_absolute_path() {
  # 1. Read input parameters
  local lab_absolute_path="$1"
  local owner_subpath="$2"
  local branch_name="$3"

  # 2. Make sure all input params are passed
  if [ -z "$lab_absolute_path" ] || [ -z "$owner_subpath" ] || [ -z "$branch_name" ]; then
    echo "Використання: compute_lab_branch_absolute_path() <lab_absolute_path> <owner_subpath> <branch_name>">&2
    return 1
  fi

  # 3. Build abs path
  # ⚠️ [owner] level does not depend on branch! Only [repo] level does.
  local abs_path="$lab_absolute_path/$owner_subpath"
  echo "$abs_path"
}

# Builds absolute path for [project] for branch in lab directory.
# Input params:
#   lab_absolute_path - abs path to [lab] directory.
#   project_subpath - like /own/translator/ or /clients/client-1/shopping/ etc.
#   branch_name - can be one from [repo, vault, runner].
compute_lab_project_branch_absolute_path() {
  # 1. Read input parameters
  local lab_absolute_path="$1"
  local project_subpath="$2"
  local branch_name="$3"

  # 2. Make sure all input params are passed
  if [ -z "$lab_absolute_path" ] || [ -z "$project_subpath" ] || [ -z "$branch_name" ]; then
    echo "Використання: compute_lab_branch_absolute_path() <lab_absolute_path> <project_subpath> <branch_name>">&2
    return 1
  fi

  # 3. Build abs path
  # ⚠️ [project] level does not depend on branch! Only [repo] level does.
  local abs_path="$lab_absolute_path/$project_subpath"
  echo "$abs_path"
}


# Builds absolute path for [repo] for branch in lab directory.
# Input params:
#   lab_absolute_path - abs path to [lab] directory.
#   repo_subpath - like /own/translator/web-extension/ or /clients/client-1/shopping/mobile-app/ etc.
#   branch_name - can be one from [repo, vault, runner].
compute_lab_repo_branch_absolute_path() {
  # 1. Read input parameters
  local lab_absolute_path="$1"
  local repo_subpath="$2"
  local branch_name="$3"

  # 2. Make sure all input params are passed
  if [ -z "$lab_absolute_path" ] || [ -z "$repo_subpath" ] || [ -z "$branch_name" ]; then
    echo "Використання: compute_lab_branch_absolute_path() <lab_absolute_path> <repo_subpath> <branch_name>">&2
    return 1
  fi

  # 3. Build abs path
  # ⚠️ [repo] level does depend on branch!
  local abs_path="$lab_absolute_path/$repo_subpath/$branch_name"
  echo "$abs_path"
}
