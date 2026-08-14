#!/bin/bash
# runner/.../repo/{{APPLE_SANDBOX_METHOD_NAME}}/run.sh
#
# Точка входу для запуску репозиторію в ізольованому середовищі.
# Делегує всю роботу в env_runner/run.sh, передаючи йому свій профіль, tests-файл
# і команду, яку користувач хоче виконати (напр. "claude" чи "bash").
#
# Використання:
#   .../patch to repo/run.sh <command> [args...]
# Приклад:
#   .../patch to repo/run.sh claude

# абсолютний шлях до env_runner/run.sh — спільної точки входу для будь-якого
# репозиторію, незалежно від методу ізоляції.
ENV_RUNNER="{{MAIN_ENV_RUNNER_ABSOLUTE_PATH}}"

# "$@" передає команду з аргументами, з якою викликали цей файл (напр. "claude"),
# далі в env_runner/run.sh без розбиття на слова чи екранування рядка
"$ENV_RUNNER" \
  --method="{{APPLE_SANDBOX_METHOD_NAME}}" \
  --profile="{{PERMISSION_PROFILE_ABSOLUTE_PATH}}" \
  --tests="{{PERMISSION_CHECK_ABSOLUTE_PATH}}" \
  -- "$@"
