#!/bin/bash
# _tools/keys/ssh/generate/repo-remote-connection/ssh-key-repo-remote-connection-generate.sh

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# Визначаємо директорію, в якій фізично лежить цей скрипт, щоб коректно підключити сусідні файли незалежно від того, звідки скрипт викликано
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Підключаємо константи
source "${SCRIPT_DIR}/constants.sh"
source "${SCRIPT_DIR}/../../../constants.sh"

# Скрипт очікує чотири позиційні аргументи:
# 1. alias репозиторію (це owner-project-repo)
# 2. абсолютний шлях до репозиторію
# 3. абсолютний шлях до vault
# 4. email, який буде вписаний у коментар (-C) публічного SSH-ключа
if [[ $# -ne 4 ]]; then
  echo "Використання: $0 <REPO_ALIAS> <REPO_ABSOLUTE_PATH> <VAULT_ABSOLUTE_PATH> <EMAIL>" >&2
  exit 1
fi

# беремо вхідні параметри
REPO_ALIAS="$1"
REPO_ABSOLUTE_PATH="$2"
VAULT_ABSOLUTE_PATH="$3"
EMAIL="$4"

# Генеруємо SSH key pair.
# Цей скрипт повертає 3 абсолютні шляхи - папку із ключами, приватний ключ і публічний ключ
# Зчитуємо всі 3 рядки виводу скрипту у масив KEY_PATHS
readarray -t SSH_KEY_GENERATION_RESULT < <(
  "${SCRIPT_DIR}/../ssh-key-generate.sh" \
    "$KEY_REPO_REMOTE_CONNECTION_NAME" \
    "$VAULT_ABSOLUTE_PATH" \
    "$EMAIL"
)
# Розпаковуємо значення з масиву у відповідні змінні
SSH_KEYS_ABSOLUTE_PATH="${SSH_KEY_GENERATION_RESULT[0]}"
PRIVATE_SSH_KEY_ABSOLUTE_PATH="${SSH_KEY_GENERATION_RESULT[1]}"
PUBLIC_SSH_KEY_ABSOLUTE_PATH="${SSH_KEY_GENERATION_RESULT[2]}"


### Тепер треба згенерувати інструкцію, як використати ці ключі із доступом до віддаленого git
### і покласти її в папку із репозиторієм.

INSTRUCTIONS_FILE_NAME=$SSH_GIT_CONNECT_INSTRUCTION_FILE_NAME
# Шлях куди покласти цю інструкцію для репозиторія.
INSTRUCTION_FILE_PATH_FROM_ROOT_REPO="$INSTRUCTIONS_FILE_NAME"
INSTRUCTIONS_FILE_ABSOLUTE_PATH="${REPO_ABSOLUTE_PATH}/$INSTRUCTION_FILE_PATH_FROM_ROOT_REPO"
# Шлях до шаблона інструкції (тут в проекті).
INSTRUCTIONS_TEMPLATE_FILE_ABSOLUTE_PATH="${SCRIPT_DIR}/templates/$INSTRUCTIONS_FILE_NAME"

## 0) перевірити чи такий файл вже є

## 1) take template 2) replace vars with values and 3) put built content into creating file.
sed \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_ALIAS/,/$REPO_ALIAS/d" \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_ABSOLUTE_PATH/,/$REPO_ABSOLUTE_PATH/d" \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_SSH_KEYS_ABSOLUTE_PATH/,/$SSH_KEYS_ABSOLUTE_PATH/d" \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_PRIVATE_SSH_KEY_ABSOLUTE_PATH/,/$PRIVATE_SSH_KEY_ABSOLUTE_PATH/d" \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_PUBLIC_SSH_KEY_ABSOLUTE_PATH/,/$PUBLIC_SSH_KEY_ABSOLUTE_PATH/d" \
  -e "/$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_INSTRUCTION_FILE_PATH_FROM_ROOT_REPO/,/$INSTRUCTION_FILE_PATH_FROM_ROOT_REPO/d" \
  "$INSTRUCTIONS_TEMPLATE_FILE_ABSOLUTE_PATH" > "$INSTRUCTIONS_FILE_ABSOLUTE_PATH"