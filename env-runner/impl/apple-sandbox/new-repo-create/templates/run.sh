#!/bin/bash
# runner/.../repo/{{APPLE_SANDBOX_METHOD_NAME}}/run.sh
#
# Точка входу для запуску репозиторію в ізольованому середовищі.
# Делегує всю роботу в env-runner/run.sh, передаючи йому свій профіль, tests-файл
# і команду, яку користувач хоче виконати (напр. "claude" чи "bash").
#
# Використання:
#   .../patch to repo/run.sh <command> [args...]
# Приклад:
#   .../patch to repo/run.sh claude
#
#
# {{TEMPLATE_VARS_DESCRIPTION}}
# 🎯готовий [run.sh] для конкретного репозиторію будується шляхом заміни змінних
# в момент копіювання цього темплейту в runners/.
# {{REPO_ABSOLUTE_PATH}}
# {{MAIN_ENV_RUNNER_ABSOLUTE_PATH}}
# {{APPLE_SANDBOX_METHOD_NAME}}
# {{PERMISSION_PROFILE_ABSOLUTE_PATH}}
# {{PERMISSION_CHECK_TESTS_ABSOLUTE_PATH}}
# {{REPO_RUNNER_VAR_HOME}}
# {{REPO_RUNNER_VAR_PATH}}
# {{TEMPLATE_VARS_DESCRIPTION}}

# перейти в папку проект
cd "{{REPO_ABSOLUTE_PATH}}"

# set HOME var to local repo path
HOME="{{REPO_RUNNER_VAR_HOME}}"
PATH="{{REPO_RUNNER_VAR_PATH}}"

# абсолютний шлях до env-runner/run.sh — спільної точки входу для будь-якого
# репозиторію, незалежно від методу ізоляції.
ENV_RUNNER="{{MAIN_ENV_RUNNER_ABSOLUTE_PATH}}"

# "$@" передає команду з аргументами, з якою викликали цей файл (напр. "claude"),
# далі в env-runner/run.sh без розбиття на слова чи екранування рядка
"$ENV_RUNNER" \
  --method="{{APPLE_SANDBOX_METHOD_NAME}}" \
  --profile="{{PERMISSION_PROFILE_ABSOLUTE_PATH}}" \
  --tests="{{PERMISSION_CHECK_TESTS_ABSOLUTE_PATH}}" \
  -- "$@"
