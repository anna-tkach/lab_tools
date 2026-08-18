#!/bin/bash
# _tools/keys/ssh/ssh-key-repo-remote-connection-generate.sh
set -euo pipefail

# Визначаємо директорію, в якій фізично лежить цей скрипт, щоб коректно підключити сусідні файли незалежно від того, звідки скрипт викликано
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Підключаємо константи рівня keys, звідки береться назва ключа для repo remote connection
source "${SCRIPT_DIR}/../constants.sh"

# Скрипт очікує два позиційні аргументи: шлях до кореня репозиторію в vault та email для коментаря ключа
if [[ $# -ne 2 ]]; then
  echo "Використання: $0 <VAULT_ABSOLUTE_PATH> <EMAIL>" >&2
  exit 1
fi

# Абсолютний шлях до кореня директорії репозиторію в vault
VAULT_ABSOLUTE_PATH="$1"
# Email, який буде вписаний у коментар (-C) публічного SSH-ключа
EMAIL="$2"

# Викликаємо базовий скрипт генерації SSH-ключа, підставляючи фіксовану назву ключа для сценарію repo remote connection
"${SCRIPT_DIR}/ssh-key-generate.sh" "$KEY_REPO_REMOTE_CONNECTION_NAME" "$VAULT_ABSOLUTE_PATH" "$EMAIL"