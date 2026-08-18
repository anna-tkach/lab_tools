#!/bin/bash
# _tools/env_runner/impl/apple-sandbox/new-repo-create/new-repo-create.sh
#
# Створює всі необхідні файли (run.sh, permissions-profile.sb, permissions-check.tests) для запуску репозиторію в apple-sandbox.
# Ці файли створюються в папці .../runners/...path to repo/apple-sandbox/, де .../runners/...path to repo/ = вхідний парематр RUNNERS_ABSOLUTE_PATH.
# а apple-sandbox тут береться із констант (це назва поточного методу).
#
# Ці файли сторюються копіюванням шаблонів із підставленнях необхідних значень.
# Необхідні знаечння для формування шаблонів:
#   REPO_ABSOLUTE_PATH - це шлях до репозиторію (.../repos/...path to repo/). Це єдина директорія, до якої має бути дорступ в цьому середовищі.
# Копіює темплейти раннера для методу apple-sandbox (permissions-profile.sb, permissions.tests, run.sh) у теку
#
# Використання:
#   new-repo-create.sh RUNNERS_ABSOLUTE_PATH REPO_ABSOLUTE_PATH

## include constants
# get current directory where current script is placed (even if someone other called it from other place).
SCRIPT_ABSOLUTE_PATH="$(dirname "$0")"
echo "SCRIPT_ABSOLUTE_PATH: $SCRIPT_ABSOLUTE_PATH"
# 1. include /env_runner/impl/apple-sandbox/new-repo-create/constants.sh
# because we need all of them.
source "$SCRIPT_ABSOLUTE_PATH/constants.sh"
# 2. include /env_runner/constants.sh
# because we need apple-sandbox method name from here.
source "$SCRIPT_ABSOLUTE_PATH/../../../constants.sh"

# 3. Build extra paths
USER_ABSOLUTE_PATH="$HOME"
USER_LAB_ABSOLUTE_PATH="$(cd "$LAB_ROOT_DIRECTORY" && pwd)"
TEXT_FILE_IN_USER_LAB_ABSOLUTE_PATH="$USER_LAB_ABSOLUTE_PATH/sandbox-test.txt"

# functions
create_file_if_needed() {
  # make sure we have 4 inputs
  if [ "$#" -ne 4 ]; then
    echo "Використання: $0 <RUNNERS_ABSOLUTE_PATH> <REPO_ABSOLUTE_PATH> <METHOD_NAME> <FILE_NAME>"
    exit 1
  fi

  # get inputs
  RUNNERS_ABSOLUTE_PATH="$1"
  REPO_ABSOLUTE_PATH="$2"
  METHOD_NAME="$3"
  FILE_NAME="$4"

  # build absolute path to all files inside runners for apple-sandbox env for the repo
  RUNNERS_METHOD_ABSOLUTE_PATH="$RUNNERS_ABSOLUTE_PATH/$METHOD_NAME"

  # make sure RUNNERS_METHOD_ABSOLUTE_PATH exists
  mkdir -p "$RUNNERS_METHOD_ABSOLUTE_PATH"

  # build absolute path to file we are going to create
  FILE_ABSOLUTE_PATH="$RUNNERS_METHOD_ABSOLUTE_PATH/$FILE_NAME"

  # check if file exists already or not.
  # if exists -> just print message and return 0.
  if [ -f "$FILE_ABSOLUTE_PATH" ]; then
    echo "  [SKIP] $FILE_ABSOLUTE_PATH вже існує"
    exit 0;
  fi

  ## Get template for file we are going to create
  # declare directory where templates are placed.
  TEMPLATES_ABSOLUTE_PATH="$SCRIPT_ABSOLUTE_PATH/templates"
  # build absolute path to the template for the file we are going to create.
  FILE_TEMPLATE_ABSOLUTE_PATH="$TEMPLATES_ABSOLUTE_PATH/$FILE_NAME"

  ## build all needed vars to replace them in the template before copying it into the runner of the repo.
  # build absolute paths for permission profile and permission check files inside of this runner (we need this paths for replacing templates with real paths).
  PERMISSION_PROFILE_ABSOLUTE_PATH="$RUNNERS_METHOD_ABSOLUTE_PATH/$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_PROFILE_FILE_NAME"
  PERMISSION_CHECK_TESTS_ABSOLUTE_PATH="$RUNNERS_METHOD_ABSOLUTE_PATH/$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_CHECK_TESTS_FILE_NAME"
  # build absolute path to the main run.sh which must be called by each repo runner.
  ENV_RUNNER_DIR="$(cd "$SCRIPT_ABSOLUTE_PATH/../../.." && pwd)"
  MAIN_ENV_RUNNER_ABSOLUTE_PATH="$ENV_RUNNER_DIR/run.sh"
  # build absolute path to the main permission-inside-self-check.sh.
  # It is required to give access to this file in this sandbox to have possibility to perform check.
  PERMISSION_CHECK_SCRIPT_ABSOLUTE_PATH="$ENV_RUNNER_DIR/permission-inside-selfcheck.sh"

  ## 1) take template 2) replace vars with values and 3) put built content into creating file.
  sed \
    -e "/$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VARS_DESCRIPTION_SECTION_NAME/,/$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VARS_DESCRIPTION_SECTION_NAME/d" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_USER_ABSOLUTE_PATH|$USER_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_USER_LAB_ABSOLUTE_PATH|$USER_LAB_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_TEXT_FILE_IN_USER_LAB_ABSOLUTE_PATH|$TEXT_FILE_IN_USER_LAB_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_REPO_ABSOLUTE_PATH|$REPO_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_MAIN_ENV_RUNNER_ABSOLUTE_PATH|$MAIN_ENV_RUNNER_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_METHOD_NAME|$METHOD_NAME|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_RUNNER_PERMISSION_PROFILE_ABSOLUTE_PATH|$PERMISSION_PROFILE_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_RUNNER_PERMISSION_CHECK_TESTS_ABSOLUTE_PATH|$PERMISSION_CHECK_TESTS_ABSOLUTE_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_RUNNER_PERMISSION_CHECK_SCRIPT_ABSOLUTE_PATH|$PERMISSION_CHECK_SCRIPT_ABSOLUTE_PATH|g" \
    "$FILE_TEMPLATE_ABSOLUTE_PATH" > "$FILE_ABSOLUTE_PATH"

  # give to current user on machine access to execute this file
  chmod u+x "$FILE_ABSOLUTE_PATH"

  echo "  [OK] File at $FILE_ABSOLUTE_PATH is created (from template)."
}

# implementation

# зупиняє виконання скрипта одразу, якщо будь-яка команда в ньому впаде
# з помилкою — без цього bash за замовчуванням ігнорує помилку і йде далі
set -euo pipefail

# make sure we have 2 inputs
if [ "$#" -ne 2 ]; then
  echo "Використання: $0 <RUNNERS_ABSOLUTE_PATH> <REPO_ABSOLUTE_PATH>"
  exit 1
fi

# read inputs into vars
RUNNERS_ABSOLUTE_PATH="$1"
REPO_ABSOLUTE_PATH="$2"

#declare other needed vars
METHOD_NAME="$ENV_RUNNER_METHOD_APPLE_SANDBOX"

## create all files if needed
# create permission profile file.
create_file_if_needed "$RUNNERS_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_PROFILE_FILE_NAME"
# create permission check file.
create_file_if_needed "$RUNNERS_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_CHECK_TESTS_FILE_NAME"
# create run.sh file for the repo.
create_file_if_needed "$RUNNERS_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_RUNNER_FILE_NAME"
echo "Раннер (метод $METHOD_NAME) для репозиторію створено."