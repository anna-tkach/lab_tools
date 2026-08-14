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


# "$(dirname "$0")" — тека, де лежить сам repos.sh
SCRIPT_DIR="$(dirname "$0")"

# підключає LAB_ROOT_DIRECTORY (шлях до кореневої директорії) і LAB_ROOT_DIRECTORY_BRANCHES (список
# паралельних дерев: repos/vault/runners)
source "$SCRIPT_DIR/_constants.sh"

# підключає _utils для визначення шляхів
source "$SCRIPT_DIR/_utils.sh"

# "${LAB_ROOT_DIRECTORY_BRANCHES[@]}" перебирає масив repos/vault/runners, визначений в _constants.sh
# і в кожній створюємо необідну структуру для кожного репо
echo "Створюю структуру для репозиторіїв '$REPOS' (owner: $OWNER, project $PROJECT)."
for TREE in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  for REPO in "${REPOS[@]}"; do
    REPO_SUBPATH=$(compute_repo_subpath "$OWNER" "$PROJECT" "$REPO")
    echo "REPO_SUBPATH '$REPO_SUBPATH'"
    REPO_DIR="$LAB_ROOT_DIRECTORY/$TREE/$REPO_SUBPATH"
    mkdir -p "$REPO_DIR"
    echo "  [OK] $REPO_DIR"
  done
done

echo "Готово. Структура створена для репозиторіїв '$REPOS' (owner: $OWNER, project $PROJECT)."
echo ""