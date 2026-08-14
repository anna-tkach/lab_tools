#!/bin/bash
# _tools/new-item-create/project.sh
#
# Створює базову структуру проєкту (теку shared/ у кожному з паралельних
# дерев кореневої директорії) для вказаного owner. Якщо теки owner ще не
# існує в repos-дереві — спершу викликає owner.sh, щоб її створити.
#
# Використання:
#   project.sh <owner> <project>
# Приклади:
#   project.sh own translator
#   project.sh client-1 billing-system

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -e

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

# підключаємо constants.sh для викорситання глобальних констант, таких яких коренева директорія та гілки.
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$TOOLS_DIR/constants.sh"

# "$(dirname "$0")" — тека, де лежить сам project.sh
SCRIPT_DIR="$(dirname "$0")"
# підключає _utils для визначення шляхів
source "$SCRIPT_DIR/_utils.sh"

PROJECT_SUBPATH=$(compute_project_subpath "$OWNER" "$PROJECT")

echo "Створюю структуру для проєкту '$PROJECT' (owner: $OWNER)"

# створюємо необхідний проект в овнері в кожній гілці.
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  PROJECT_DIR="$LAB_ROOT_DIRECTORY/$BRANCH/$PROJECT_SUBPATH"
  # TODO - i don't know i this shared directory really needed
  mkdir -p "$PROJECT_DIR/shared"
  echo "  [OK] $PROJECT_DIR/shared"
done

echo "Готово. Структура створена для проєкту '$PROJECT' (owner: $OWNER)."
echo ""