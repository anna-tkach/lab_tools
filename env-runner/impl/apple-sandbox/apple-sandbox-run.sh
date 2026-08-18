#!/bin/bash
# _tools/env-runner/impl/apple-sandbox-run.sh
#
# Конкретна реалізація запуску ізольованого середовища через macOS sandbox-exec.
# Викликається з run.sh, коли METHOD=apple-sandbox.
#
# Параметри (позиційні, приходять вже перевіреними від run.sh):
#   $1 — шлях до .sb-профілю
#   $2 — шлях до tests-файлу
#   $3, $4, ... — команда для фінальної сесії (масив аргументів)
#
# Повертає:
#   0 — сесія завершилась нормально
#   не 0 — перевірка не пройдена, або фінальна команда завершилась з помилкою

PROFILE_FILE="$1"
TESTS_FILE="$2"
shift 2
FINAL_COMMAND=("$@")

# шлях до селфчек-скрипта: він лежить на рівень вище теки impl/
SELFCHECK="$(dirname "$0")/../../permission-inside-selfcheck.sh"

# без цього файлу немає сенсу запускати sandbox взагалі — перевірка прав не відбудеться
if [ ! -f "$SELFCHECK" ]; then
  echo "Файл перевірки не знайдено: $SELFCHECK"
  exit 1
fi

# printf '%q' огортає значення так, щоб пробіли й спецсимволи в шляху не розбили
# рядок команди нижче на частини при підстановці в bash -c "..."
QUOTED_TESTS_FILE=$(printf '%q' "$TESTS_FILE")
QUOTED_SELFCHECK=$(printf '%q' "$SELFCHECK")

# кожен елемент масиву команди екранується окремо і додається в один рядок,
# щоб команда з аргументами (напр. claude --model sonnet) дійшла до exec цілою,
# а не розпалась чи не змішалась в одне слово
QUOTED_COMMAND=""
for arg in "${FINAL_COMMAND[@]}"; do
  QUOTED_COMMAND+=" $(printf '%q' "$arg")"
done

# sandbox-exec обмежує ОДИН процес (bash) і всі його нащадки; тому selfcheck
# і фінальна команда виконуються послідовно всередині одного виклику, а не
# окремими sandbox-exec запусками — інакше обмеження б не переносились між ними
sandbox-exec -f "$PROFILE_FILE" bash -c "
  bash $QUOTED_SELFCHECK $QUOTED_TESTS_FILE

  # \$? тут — exit code selfcheck, отриманий одразу після його завершення
  if [ \$? -ne 0 ]; then
    echo 'Перевірка не пройдена — сесію закрито.'
    exit 1
  fi

  # exec підміняє поточний bash-процес на фінальну команду замість того, щоб
  # створити новий процес — так sandbox-обмеження лишаються чинними і для неї
  exec $QUOTED_COMMAND
"

exit $?