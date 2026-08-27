#!/bin/bash
# _tools/utils_subpaths_computing.sh
#
# Файл не запускається сам по собі — інші скрипти підключають його через "source".

# Перетворює owner на підшлях у кожному дереві кореневої директорії:
# "own" стає "own", "client-1" стає "clients/client-1".
# Використання: owner_path=$(compute_owner_path "$OWNER")
# subpath (not path) means - sender must add some root directory before!
compute_owner_subpath() {
  local owner="$1"

  if [ -z "$owner" ]; then
    echo "Error: compute_owner_subpath() owner is required" >&2
    return 1
  fi

  if [ "$owner" == "own" ]; then
    echo "own"
  elif [ "$owner" == "learning" ]; then
    echo "learning"
  else
    echo "clients/$owner"
  fi
}

# Перетворює owner і project на підшлях всередині кожного дерева кореневої
# директорії: "own" + "translator" стає "own/translator",
# "client-1" + "billing" стає "clients/client-1/billing".
# Використання: project_path=$(compute_project_path "$OWNER" "$PROJECT")
# subpath (not path) means - sender must add some root directory before!
compute_project_subpath() {
  local owner="$1"
  local project="$2"

  if [ -z "$owner" ] || [ -z "$project" ]; then
    echo "Error: compute_project_subpath() owner and project are required" >&2
    return 1
  fi

  local owner_path
  owner_path=$(compute_owner_subpath "$owner")

  echo "$owner_path/$project"
}

# Перетворює owner і project i repo на підшлях всередині кожного дерева кореневої
# директорії: "own" + "translator" + "web-extension" -Ю "own/translator/web-extension"
# "client-1" + "billing" + backend стає "clients/client-1/billing/backend".
# Використання: project_path=$(compute_project_path "$OWNER" "$PROJECT" "$REPO")
# subpath (not path) means - sender must add some root directory before!
compute_repo_subpath() {
  local owner="$1"
  local project="$2"
  local repo="$3"

  if [ -z "$owner" ] || [ -z "$project" ]; then
      echo "Error: compute_repo_subpath() owner and project and repo are required" >&2
      return 1
    fi

  local project_path
  project_path=$(compute_project_subpath "$owner" "$project")

  echo "$project_path/$repo"
}