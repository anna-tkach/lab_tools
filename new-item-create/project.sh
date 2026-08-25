#!/bin/bash
# _tools/new-item-create/project.sh
#
# Створює базову структуру проєкту (теку shared/ у кожному з паралельних
# дерев кореневої директорії) для вказаного owner. Якщо теки owner ще не
# існує в repos-дереві — спершу викликає owner.sh, щоб її створити.
#
# Використання:
#   sh project.sh <owner> <project>
# Приклади:
#   sh project.sh own translator
#   sh project.sh client-1 billing-system

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Використання: $0 <owner> <project>"
  exit 1
fi

OWNER="$1"
PROJECT="$2"

# "$(dirname "$0")" — тека, де лежить цей скрипт
SCRIPT_DIR="$(dirname "$0")"

# Будуємо необхідні директорії для овнера (якщо вони вже є - нічого не зламається, просто не створяться папки)
"$SCRIPT_DIR/owner.sh" "$OWNER"

# визначаємо шлях коренової папки _tools для подальшого підключення необхідних файлів.
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# підключаємо constants.sh для викорситання глобальних констант, таких яких коренева директорія та гілки.
source "$TOOLS_DIR/constants.sh"
# підключає utils для визначення шляхів
source "$TOOLS_DIR/utils_paths_computing.sh"
source "$TOOLS_DIR/utils_subpaths_computing.sh"


# створюємо необхідний проект в овнері в кожній гілці.
echo "Створюю структуру для проєкту '$PROJECT' (owner: $OWNER)"
PROJECT_SUBPATH=$(compute_project_subpath "$OWNER" "$PROJECT")
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  BRANCH_ABSOLUTE_PATH=$(compute_lab_project_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$PROJECT_SUBPATH" "$BRANCH")
  echo "BRANCH_ABSOLUTE_PATH: $BRANCH_ABSOLUTE_PATH"
  mkdir -p "$BRANCH_ABSOLUTE_PATH"
  echo "  [OK] $BRANCH_ABSOLUTE_PATH"
done

echo "Готово. Структура створена для проєкту '$PROJECT' (owner: $OWNER)."
echo ""