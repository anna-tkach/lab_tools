#!/bin/bash
# _tools/env-runner/impl/apple-sandbox/new-repo-create/new-repo-create.sh
#
# Створює всі необхідні файли (run.sh, permissions-profile.sb, permissions-check.tests) для запуску репозиторію в apple-sandbox.
# Ці файли створюються в папці .../runners/...path to repo/apple-sandbox/, де .../runners/...path to repo/ = вхідний парематр RUNNER_ABSOLUTE_PATH.
# а apple-sandbox тут береться із констант (це назва поточного методу).
#
# Ці файли сторюються копіюванням шаблонів із підставленнях необхідних значень.
# Необхідні знаечння для формування шаблонів:
#   REPO_ABSOLUTE_PATH - це шлях до репозиторію (.../repos/...path to repo/). Це єдина директорія, до якої має бути дорступ в цьому середовищі.
# Копіює темплейти раннера для методу apple-sandbox (permissions-profile.sb, permissions.tests, run.sh) у теку
#
# Використання:
#   sh new-repo-create.sh <REPO_ABSOLUTE_PATH> <RUNNER_ABSOLUTE_PATH> <USER_NAME> <USER_EMAIL>

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

## include constants
# get current directory where current script is placed (even if someone other called it from other place).
SCRIPT_ABSOLUTE_PATH="$(dirname "$0")"
echo "SCRIPT_ABSOLUTE_PATH: $SCRIPT_ABSOLUTE_PATH"
# 1. include /env-runner/impl/apple-sandbox/new-repo-create/constants.sh
# because we need all of them.
source "$SCRIPT_ABSOLUTE_PATH/constants.sh"
# 2. include /env-runner/constants.sh
# because we need apple-sandbox method name from here.
source "$SCRIPT_ABSOLUTE_PATH/../../../constants.sh"

# 3. include /constants.sh
# because we need root lab directory.
source "$SCRIPT_ABSOLUTE_PATH/../../../../constants.sh"

# 3. Build extra paths
USER_ABSOLUTE_PATH="$HOME"
USER_LAB_ABSOLUTE_PATH="$(cd "$LAB_ROOT_DIRECTORY" && pwd)"
TEXT_FILE_IN_USER_LAB_ABSOLUTE_PATH="$USER_LAB_ABSOLUTE_PATH/sandbox-test.txt"

## functions

# creates .env/             - this must be $HOME for runner.
#         .env/.gitconfig   - this config needed for git with this $HOME.
create_home_env() {
  local env_absolute_path="$1"
  local user_name="$2"
  local user_email="$3"

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  local gitconfig_file_abs_path="${env_absolute_path}/.gitconfig"

  # Перевіряємо, чи файл вже існує
  if [ -f "$gitconfig_file_abs_path" ]; then
    echo "File already exists, skipping: $gitconfig_file_abs_path"
    return 0
  fi

  # Створюємо папку .env (якщо її немає)
  mkdir -p "$env_absolute_path"

  # Записуємо конфігурацію, оскільки файлу ще не було
  cat <<EOF > "$gitconfig_file_abs_path"
[user]
	name = $user_name
	email = $user_email
EOF

  echo "Created: $gitconfig_file_abs_path"
}

create_file_if_needed() {
  # make sure we have 5 inputs
  if [ "$#" -ne 5 ]; then
    echo "Використання: $0 <RUNNER_ABSOLUTE_PATH> <REPO_ABSOLUTE_PATH> <REPO_RUNNER_VAR_HOME> <METHOD_NAME> <FILE_NAME>"
    exit 1
  fi

  # get inputs
  RUNNER_ABSOLUTE_PATH="$1"
  REPO_ABSOLUTE_PATH="$2"
  REPO_RUNNER_VAR_HOME="$3"
  METHOD_NAME="$4"
  FILE_NAME="$5"

  # build absolute path to all files inside runners for apple-sandbox env for the repo
  RUNNERS_METHOD_ABSOLUTE_PATH="$RUNNER_ABSOLUTE_PATH/$METHOD_NAME"

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
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_REPO_RUNNER_VAR_PATH|$REPO_RUNNER_VAR_PATH|g" \
    -e "s|$ENV_RUNNER_METHOD_APPLE_SANDBOX_TEMPLATES_VAR_REPO_RUNNER_VAR_HOME|$REPO_RUNNER_VAR_HOME|g" \
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
if [ "$#" -ne 4 ]; then
  echo "Використання: $0 <REPO_ABSOLUTE_PATH> <RUNNER_ABSOLUTE_PATH> <USER_NAME> <USER_EMAIL>"
  exit 1
fi

# read inputs into vars
REPO_ABSOLUTE_PATH="$1"
RUNNER_ABSOLUTE_PATH="$2"
USER_NAME="$3"
USER_EMAIL="$4"

#declare other needed vars
METHOD_NAME="$ENV_RUNNER_METHOD_APPLE_SANDBOX"

## create .env folder inside of runner and create .gitconfig file with user name and email
ENV_FOLDER_ABSOLUT_PATH="${RUNNER_ABSOLUTE_PATH}/$ENV_RUNNER_METHOD_APPLE_SANDBOX_RUNNER_ENV_FOLDER_NAME"
create_home_env "$ENV_FOLDER_ABSOLUT_PATH" "$USER_NAME" "$USER_EMAIL"

## create all files if needed
# create permission profile file.
create_file_if_needed "$RUNNER_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$ENV_FOLDER_ABSOLUT_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_PROFILE_FILE_NAME"
# create permission check file.
create_file_if_needed "$RUNNER_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$ENV_FOLDER_ABSOLUT_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_PERMISSION_CHECK_TESTS_FILE_NAME"
# create run.sh file for the repo.
create_file_if_needed "$RUNNER_ABSOLUTE_PATH" "$REPO_ABSOLUTE_PATH" "$ENV_FOLDER_ABSOLUT_PATH" "$METHOD_NAME" "$ENV_RUNNER_METHOD_APPLE_SANDBOX_RUNNER_FILE_NAME"

echo "Раннер (метод $METHOD_NAME) для репозиторію створено."
echo ""


