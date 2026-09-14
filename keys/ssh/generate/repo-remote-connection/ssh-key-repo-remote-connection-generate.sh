#!/bin/bash
# _tools/keys/ssh/generate/repo-remote-connection/ssh-key-repo-remote-connection-generate.sh

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# Визначаємо директорію, в якій фізично лежить цей скрипт, щоб коректно підключити сусідні файли незалежно від того, звідки скрипт викликано
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Підключаємо константи
source "${SCRIPT_DIR}/constants.sh"
# константи рівня keys (спільні для всіх типів ключів)
source "${SCRIPT_DIR}/../../../constants.sh"

# Скрипт очікує п'ять позиційних аргументів:
# 1. alias репозиторію (це owner-project-repo)
# 2. абсолютний шлях до репозиторію
# 3. абсолютний шлях до vault
# 4. email, який буде вписаний у коментар (-C) публічного SSH-ключа
# 5. абсолютний шлях до файлу git-інструкції (обчислюється в repo.sh, єдиному місці,
#    яке знає про теку .instructions/), потрібен щоб підставити його в шаблон інструкції.
if [[ $# -ne 5 ]]; then
  echo "Використання: $0 <REPO_ALIAS> <REPO_ABSOLUTE_PATH> <VAULT_ABSOLUTE_PATH> <EMAIL> <REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH>" >&2
  exit 1
fi

# беремо вхідні параметри
REPO_ALIAS="$1"
REPO_ABSOLUTE_PATH="$2"
VAULT_ABSOLUTE_PATH="$3"
EMAIL="$4"
REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH="$5"


# Генеруємо шляхи - куди і які файли будуть генеруватися.
source "${SCRIPT_DIR}/../utils_paths_computing.sh"
SSH_KEYS_PATHS=()
while IFS= read -r line; do
  [[ -n "$line" ]] && SSH_KEYS_PATHS+=("$line")
done < <(compute_ssh_keys_paths "$KEY_REPO_REMOTE_CONNECTION_NAME" "$VAULT_ABSOLUTE_PATH")
# Розпаковуємо значення з масиву у відповідні змінні
SSH_KEYS_ABSOLUTE_PATH="${SSH_KEYS_PATHS[0]}"
SSH_PRIVATE_KEY_ABSOLUTE_PATH="${SSH_KEYS_PATHS[1]}"
SSH_PUBLIC_KEY_ABSOLUTE_PATH="${SSH_KEYS_PATHS[2]}"

# Генеруємо SSH key pair.
"${SCRIPT_DIR}/../ssh-key-generate.sh" "$SSH_KEYS_ABSOLUTE_PATH" "$SSH_PRIVATE_KEY_ABSOLUTE_PATH" "$SSH_PUBLIC_KEY_ABSOLUTE_PATH" "$EMAIL"


### Тепер треба згенерувати інструкцію, як використати ці ключі із доступом до віддаленого git
### і покласти її в теку інструкцій репозиторія (ця тека повністю заборонена в sandbox раннера).
### Цей скрипт нічого не знає про назву чи розташування цієї теки - лише про готовий
### абсолютний шлях до файлу інструкції, отриманий як вхідний параметр.

INSTRUCTIONS_FILE_NAME=$SSH_GIT_CONNECT_INSTRUCTION_FILE_NAME
# Тека, що містить файл інструкції, має існувати перед записом файлу в неї.
mkdir -p "$(dirname "$REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH")"
# Шлях куди покласти цю інструкцію відносно кореня репозиторія (для .git/info/exclude) -
# просто прибираємо префікс кореня репозиторія з уже відомого абсолютного шляху.
INSTRUCTION_FILE_PATH_FROM_ROOT_REPO="${REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH#${REPO_ABSOLUTE_PATH}/}"
# Шлях до шаблона інструкції (тут в проекті).
INSTRUCTIONS_TEMPLATE_FILE_ABSOLUTE_PATH="${SCRIPT_DIR}/templates/$INSTRUCTIONS_FILE_NAME"

## 0) перевірити чи такий файл вже є

## 1) take template 2) replace vars with values and 3) put built content into creating file.
sed \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_ALIAS|$REPO_ALIAS|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_ABSOLUTE_PATH|$REPO_ABSOLUTE_PATH|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_SSH_KEYS_ABSOLUTE_PATH|$SSH_KEYS_ABSOLUTE_PATH|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_SSH_PRIVATE_KEY_ABSOLUTE_PATH|$SSH_PRIVATE_KEY_ABSOLUTE_PATH|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_SSH_PUBLIC_KEY_ABSOLUTE_PATH|$SSH_PUBLIC_KEY_ABSOLUTE_PATH|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_GIT_INSTRUCTION_FILE_PATH_FROM_ROOT_REPO|$INSTRUCTION_FILE_PATH_FROM_ROOT_REPO|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH|$REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH|g" \
  -e "s|$SSH_GIT_CONNECT_INSTRUCTION_TEMPLATES_VAR_EMAIL|$EMAIL|g" \
  "$INSTRUCTIONS_TEMPLATE_FILE_ABSOLUTE_PATH" > "$REPO_GIT_INSTRUCTION_FILE_ABSOLUTE_PATH"
