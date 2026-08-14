#!/bin/bash
# ~/lab/tools/new-project.sh
#
# Використання:
#   new-project.sh <owner> <project> <repo1> [repo2] [repo3] ...
#
# Приклади:
#   new-project.sh own translator browser-extension mobile-app
#   new-project.sh client-1 billing-system backend frontend

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -e

# усі 3 вхідні параметри мають - інакше скрипт закінчується із помилкою
if [ "$#" -lt 3 ]; then
  echo "Використання: $0 <owner> <project> <repo1> [repo2] ..."
  echo "  owner: 'own' або назва клієнта, напр. 'client-1'"
  exit 1
fi

# зчитуємо 3 необхідні вхідні парметри
OWNER="$1"
PROJECT="$2"
shift 2
REPOS=("$@")   # усі решта аргументів — список репозиторіїв


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


echo "Створюю структуру для репозиторіїв '$REPOS' (owner: $OWNER, project $PROJECT)."
# створюємо необхідні репозиторії (із необхідною структурою) в проекті в овнері в кожній гілці.
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  for REPO in "${REPOS[@]}"; do
    REPO_SUBPATH=$(compute_repo_subpath "$OWNER" "$PROJECT" "$REPO")
    echo "REPO_SUBPATH '$REPO_SUBPATH'"
    REPO_DIR="$LAB_ROOT_DIRECTORY/$BRANCH/$REPO_SUBPATH"
    mkdir -p "$REPO_DIR"
    echo "  [OK] $REPO_DIR"
  done
done

echo "Готово. Структура створена для репозиторіїв '$REPOS' (owner: $OWNER, project $PROJECT)."
echo ""