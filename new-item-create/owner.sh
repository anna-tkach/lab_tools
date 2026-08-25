#!/bin/bash
# _tools/new-item-create/owner.sh
#
# Створює базову теку для owner (own або конкретний клієнт) у кожному з
# паралельних дерев кореневої директорії. Це найнижчий рівень каскаду —
# нічого іншого не викликає, бо owner не залежить від жодного вищого рівня.
#
# Використання:
#   sh owner.sh <owner>
# Приклади:
#   sh owner.sh own
#   sh owner.sh client-1

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Використання: $0 <owner>"
  echo "  owner: 'own' або назва клієнта, напр. 'client-1'"
  exit 1
fi

OWNER="$1"

# визначаємо шлях коренової папки _tools для подальшого підключення необхідних файлів.
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# підключаємо constants.sh для викорситання глобальних констант, таких яких коренева директорія та гілки.
source "$TOOLS_DIR/constants.sh"
# підключає utils для визначення шляхів
source "$TOOLS_DIR/utils_paths_computing.sh"
source "$TOOLS_DIR/utils_subpaths_computing.sh"

# створюємо необхідного овнера в кожній гілці.
echo "Створюю базову структуру для owner '$OWNER'."
OWNER_SUBPATH=$(compute_owner_subpath "$OWNER")
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  BRANCH_ABSOLUTE_PATH=$(compute_lab_owner_branch_absolute_path "$LAB_ROOT_DIRECTORY" "$OWNER_SUBPATH" "$BRANCH")
  echo "BRANCH_ABSOLUTE_PATH: $BRANCH_ABSOLUTE_PATH"
  mkdir -p "$BRANCH_ABSOLUTE_PATH"
  echo "  [OK] $BRANCH_ABSOLUTE_PATH"
done
echo "Готово. Структура створена для owner '$OWNER'."
echo ""