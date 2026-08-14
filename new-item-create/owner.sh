#!/bin/bash
# _tools/new-item-create/owner.sh
#
# Створює базову теку для owner (own або конкретний клієнт) у кожному з
# паралельних дерев кореневої директорії. Це найнижчий рівень каскаду —
# нічого іншого не викликає, бо owner не залежить від жодного вищого рівня.
#
# Використання:
#   owner.sh <owner>
# Приклади:
#   owner.sh own
#   owner.sh client-1

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -e

if [ "$#" -ne 1 ]; then
  echo "Використання: $0 <owner>"
  echo "  owner: 'own' або назва клієнта, напр. 'client-1'"
  exit 1
fi

OWNER="$1"

# підключаємо constants.sh для викорситання глобальних констант, таких яких коренева директорія та гілки.
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$TOOLS_DIR/constants.sh"

# "$(dirname "$0")" — тека, де лежить сам owner.sh; шлях до підключених
# файлів будується відносно неї, щоб виклик працював незалежно від того,
# з якої директорії власне запущено owner.sh
SCRIPT_DIR="$(dirname "$0")"
# підключає _utils для визначення шляхів
source "$SCRIPT_DIR/_utils.sh"

OWNER_SUBPATH=$(compute_owner_subpath "$OWNER")

# створюємо необхідного овнера в кожній гілці.
echo "Створюю базову структуру для owner '$OWNER'."
for BRANCH in "${LAB_ROOT_DIRECTORY_BRANCHES[@]}"; do
  OWNER_DIR="$LAB_ROOT_DIRECTORY/$BRANCH/$OWNER_SUBPATH"
  mkdir -p "$OWNER_DIR"
  echo "  [OK] $OWNER_DIR"
done
echo "Готово. Структура створена для owner '$OWNER'."
echo ""