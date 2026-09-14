#!/bin/bash
# _tools/new-item-create/repo.sh
#
# Використання:
#   sh repo.sh <owner> <project> <repo> <email>
#
# Приклади:
#   sh repo.sh own translator browser-extension email@test.com
#   sh repo.sh client-1 billing-system backend email@test.com

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# усі 3 вхідні параметри мають - інакше скрипт закінчується із помилкою
if [ "$#" -lt 4 ]; then
  echo "Використання: $0 <owner> <project> <repo> <email>"
  echo "  owner: 'own' або назва клієнта, напр. 'client-1'"
  exit 1
fi

# зчитуємо 3 необхідні вхідні парметри
OWNER="$1"
PROJECT="$2"
REPO="$3"
EMAIL="$4"

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
source "$TOOLS_DIR/utils_paths_computing.sh"
source "$TOOLS_DIR/utils_subpaths_computing.sh"

echo "Створюється репозиторій: '$REPO' (owner: $OWNER, project $PROJECT)..."
# створюємо необхідний репозиторій (із необхідною структурою) в проекті в овнері в кожній гілці.
# 0. for repo build su path
REPO_SUBPATH=$(compute_repo_subpath "$OWNER" "$PROJECT" "$REPO")
echo "REPO_SUBPATH '$REPO_SUBPATH'"

# 1. for the repo create structure for all branches
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  BRANCH_ABSOLUTE_PATH=$(compute_lab_repo_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$REPO_SUBPATH" "$BRANCH")
  echo "BRANCH_ABSOLUTE_PATH: $BRANCH_ABSOLUTE_PATH"
  mkdir -p "$BRANCH_ABSOLUTE_PATH"
  echo "  [OK] $BRANCH_ABSOLUTE_PATH"
done
echo "Крок 1️⃣  готово. Створено структуру."
echo ""

# підключаємо утиліту обчислення шляху до файлу git-інструкції
# (сам файл створюється на кроці 3, але шлях до нього потрібен вже на кроці 2 для sandbox-профілю раннера).
source "$TOOLS_DIR/keys/ssh/generate/repo-remote-connection/utils_paths_computing.sh"

# 2. for repo create runner in /runners/ branch.
REPO_ABSOLUTE_PATH=$(compute_lab_repo_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$REPO_SUBPATH" "$LAB_ROOT_DIRECTORY_BRANCH_REPO")
RUNNER_ABSOLUTE_PATH=$(compute_lab_repo_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$REPO_SUBPATH" "$LAB_ROOT_DIRECTORY_BRANCH_RUNNERS")
# Тільки top-level (repo.sh) знає назву теки .instructions/ - жоден інший модуль її не знає.
REPO_INSTRUCTIONS_FOLDER_ABSOLUTE_PATH="$REPO_ABSOLUTE_PATH/$REPO_INSTRUCTIONS_FOLDER_NAME"
REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH=$(compute_git_instruction_file_absolute_path_by_instructions_folder_absolute_path "$REPO_INSTRUCTIONS_FOLDER_ABSOLUTE_PATH")
"$TOOLS_DIR/env-runner/new-repo-create.sh" "$REPO_ABSOLUTE_PATH" "$RUNNER_ABSOLUTE_PATH" "$LAB_GIT_USER_NAME" "$EMAIL" "$REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH"
echo "Крок️ 2️⃣  готово. Створено runner.sh (в .../runners/...)."
echo ""

# 3. for repo generate ssh-key for repo-remote-connection in /vault/ branch.
VAULT_ABSOLUTE_PATH=$(compute_lab_repo_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$REPO_SUBPATH" "$LAB_ROOT_DIRECTORY_BRANCH_VAULT")
REPO_ALIAS="$OWNER-$PROJECT-$REPO"
"$TOOLS_DIR/keys/ssh/generate/repo-remote-connection/ssh-key-repo-remote-connection-generate.sh" "$REPO_ALIAS" "$REPO_ABSOLUTE_PATH" "$VAULT_ABSOLUTE_PATH" "$EMAIL" "$REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH"
echo "Крок 3️⃣  готово. Створено зашифрований shh ключ (в .../vault/...)."
echo ""

echo "✅ Створено репозиторій."
echo ""