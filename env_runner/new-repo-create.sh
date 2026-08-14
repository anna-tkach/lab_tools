#!/bin/bash
# _tools/env_runner/new-repo-create.sh
#
# Оркестратор: не знає нічого про конкретний метод ізоляції, лише перебирає
# список ENV_RUNNER_METHODS і викликає власний new-repo-create.sh кожного
# методу, передаючи йому owner/project/repo. Кожен метод сам вирішує, які
# файли раннера йому потрібні і як їх створити.
#
# Використання:
#   new-repo-create.sh <owner> <project> <repo>

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -e

if [ "$#" -ne 2 ]; then
  echo "Використання: $0 <RUNNERS_ABSOLUTE_PATH> <REPO_ABSOLUTE_PATH>"
  exit 1
fi

RUNNERS_ABSOLUTE_PATH="$1"
REPO_ABSOLUTE_PATH="$2"

# "$(dirname "$0")" — тека, де лежить сам new-repo-create.sh, тобто env_runner/
SCRIPT_DIR="$(dirname "$0")"
# підключаємо з constants.sh на цьому ж рівні, там лежать ENV_RUNNER_METHODS
source "$SCRIPT_DIR/constants.sh"

for METHOD in "${ENV_RUNNER_METHODS[@]}"; do
  IMPL_SCRIPT="$SCRIPT_DIR/impl/$METHOD/new-repo-create/new-repo-create.sh"

  # захист від відсутньої реалізації: якщо метод є в списку, але для нього
  # ще не написано new-repo-create.sh, краще впасти з чіткою помилкою,
  # ніж мовчки пропустити метод
  if [ ! -f "$IMPL_SCRIPT" ]; then
    echo "Реалізацію для методу '$METHOD' не знайдено: $IMPL_SCRIPT"
    exit 1
  fi

  echo "Створюю раннер методу '$METHOD' для репозиторію '$REPO'..."
  "$IMPL_SCRIPT" "$RUNNERS_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH"
done
