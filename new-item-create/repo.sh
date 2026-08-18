#!/bin/bash
# _tools/new-item-create/repo.sh
#
# Використання:
#   new-project.sh <owner> <project> <repo>
#
# Приклади:
#   new-project.sh own translator browser-extension
#   new-project.sh client-1 billing-system backend

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# усі 3 вхідні параметри мають - інакше скрипт закінчується із помилкою
if [ "$#" -lt 3 ]; then
  echo "Використання: $0 <owner> <project> <repo>"
  echo "  owner: 'own' або назва клієнта, напр. 'client-1'"
  exit 1
fi

# зчитуємо 3 необхідні вхідні парметри
OWNER="$1"
PROJECT="$2"
REPO="$3"

# "$(dirname "$0")" — тека, де лежить цей скрипт
SCRIPT_DIR="$(dirname "$0")"

# Будуємо необхідні директорії для проекта
# (якщо вони вже є - нічого не зламається, просто не створяться папки.
# створення проекта в совю чергу створить овнера при необхідності)
"$SCRIPT_DIR/project.sh" "$OWNER" "$PROJECT"

# визначаємо шлях коренової папки _tools для подальшого підключення необхідних файлів.
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# підключаємо constants.sh для викорситання глобальних констант, таких яких коренева директорія та гілки.
source "$TOOLS_DIR/constants.sh"
# підключає utils для визначення шляхів
source "$TOOLS_DIR/utils_subpaths_computing.sh"

echo "Створюю структуру для репозиторія '$REPO' (owner: $OWNER, project $PROJECT)."
# створюємо необхідний репозиторій (із необхідною структурою) в проекті в овнері в кожній гілці.
# 0. for repo build su path
REPO_SUBPATH=$(compute_repo_subpath "$OWNER" "$PROJECT" "$REPO")
echo "REPO_SUBPATH '$REPO_SUBPATH'"

# 1. for the repo create structure for all branches
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  REPO_DIR="$LAB_ROOT_DIRECTORY/$BRANCH/$REPO_SUBPATH"
  mkdir -p "$REPO_DIR"
  echo "  [OK] $REPO_DIR"
done

# 2. for repo create runner in /runners/ branch & ssh in /vault/ branch.
REPO_ABSOLUTE_PATH="$LAB_ROOT_DIRECTORY/$LAB_ROOT_DIRECTORY_BRANCH_REPOS/$REPO_SUBPATH"
RUNNER_ABSOLUTE_PATH="$LAB_ROOT_DIRECTORY/$LAB_ROOT_DIRECTORY_BRANCH_RUNNERS/$REPO_SUBPATH"
"$TOOLS_DIR/env_runner/new-repo-create.sh" "$REPO_ABSOLUTE_PATH" "$RUNNER_ABSOLUTE_PATH"

echo "Готово. Структура створена для репозиторія '$REPO' (owner: $OWNER, project $PROJECT)."
echo ""