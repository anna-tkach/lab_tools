#!/bin/bash
# {{REPO_NAME}}.run.sh
#
# Точка входу для запуску репозиторію "{{REPO_NAME}}" в ізольованому середовищі.
# Делегує всю роботу в env_runner/run.sh, передаючи йому свій профіль, tests-файл
# і команду, яку користувач хоче виконати (напр. "claude" чи "bash").
#
# Використання:
#   ./{{REPO_NAME}}.run.sh <command> [args...]
# Приклад:
#   ./{{REPO_NAME}}.run.sh claude

# "$(dirname "$0")" — тека, де лежить сам цей файл; профіль і tests-файл
# лежать поруч з ним, тому шлях будується відносно нього
SCRIPT_DIR="$(dirname "$0")"

# абсолютний шлях до env_runner/run.sh — спільної точки входу для будь-якого
# репозиторію, незалежно від методу ізоляції
ENV_RUNNER="$HOME/lab/_tools/env_runner/run.sh"

# "$@" передає команду з аргументами, з якою викликали цей файл (напр. "claude"),
# далі в env_runner/run.sh без розбиття на слова чи екранування рядка
"$ENV_RUNNER" \
  --method=apple-sandbox \
  --profile="$SCRIPT_DIR/{{REPO_NAME}}.sb" \
  --tests="$SCRIPT_DIR/{{REPO_NAME}}.tests" \
  -- "$@"
