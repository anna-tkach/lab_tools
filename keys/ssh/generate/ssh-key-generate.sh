#!/bin/bash
# _tools/keys/ssh/ssh-key-generate.sh


# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# "$(dirname "$0")" — тека, де лежить цей скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Підключаємо константи рівня ssh (специфічні для SSH-ключів)
source "${SCRIPT_DIR}/../constants.sh"
# Підключаємо константи рівня keys (спільні для всіх типів ключів)
source "${SCRIPT_DIR}/../../constants.sh"

# Скрипт очікує три позиційні аргументи: ім'я ключа, шлях до кореня репозиторію в vault та email для коментаря ключа
if [[ $# -ne 3 ]]; then
  echo "Використання: $0 <KEY_NAME> <VAULT_ABSOLUTE_PATH> <EMAIL>" >&2
  exit 1
fi

# Ім'я конкретного ключа (наприклад repo-remote-connection), яке визначає його призначення
KEY_NAME="$1"
# Абсолютний шлях до кореня директорії репозиторію в vault
VAULT_ABSOLUTE_PATH="$2"
# Email, який буде вписаний у коментар (-C) публічного SSH-ключа
EMAIL="$3"

# Директорія для ключів усіх типів цього репозиторію, зібрана з константи рівня keys
KEYS_DIR="${VAULT_ABSOLUTE_PATH}/${KEYS_VAULT_FOLDER_NAME}"
# Піддиректорія саме для SSH-ключів цього репозиторію, зібрана з константи рівня ssh
SSH_DIR="${KEYS_DIR}/${SSH_VAULT_FOLDER_NAME}"
# Повний шлях до приватного ключа з переданим іменем
PRIVATE_KEY_PATH="${SSH_DIR}/${KEY_NAME}"
# Повний шлях до публічного ключа, що відповідає приватному
PUBLIC_KEY_PATH="${PRIVATE_KEY_PATH}.pub"

# Перевіряємо, чи вже існує приватний ключ саме з таким іменем у цій директорії
if [[ -f "$PRIVATE_KEY_PATH" ]]; then
  echo "SSH-ключ '${KEY_NAME}' для '${VAULT_ABSOLUTE_PATH}' вже існує: ${PRIVATE_KEY_PATH}. Створення пропущено." >&2
  # Повертаємо шляхи до стандартного потоку виводу (stdout)
  echo "$SSH_DIR"
  echo "$PRIVATE_KEY_PATH"
  echo "$PUBLIC_KEY_PATH"
  exit 0
fi

# Створюємо директорію keys/ssh разом з батьківськими, якщо їх ще немає (mkdir -p ідемпотентний)
mkdir -p "$SSH_DIR"

echo "Створюємо новий SSH-ключ (${SSH_TYPE}) з іменем '${KEY_NAME}' у ${PRIVATE_KEY_PATH}" >&2
echo "Зараз потрібно буде ввести passphrase (двічі) — приватний ключ буде зашифровано ним на диску." >&2

# Генеруємо пару ключів; без -N, тому ssh-keygen сам інтерактивно запитає passphrase
ssh-keygen -t "$SSH_TYPE" -C "$EMAIL" -f "$PRIVATE_KEY_PATH"

# Перевіряємо, чи можна прочитати приватний ключ з порожнім паролем — якщо так, значить passphrase не було введено
if ssh-keygen -y -P "" -f "$PRIVATE_KEY_PATH" >/dev/null 2>&1; then
  echo "❌ Passphrase не було введено — приватний ключ лишився незашифрованим, що заборонено." >&2
  # Видаляємо обидва файли пари, оскільки незашифрований ключ не відповідає вимогам безпеки
  rm -f "$PRIVATE_KEY_PATH" "$PUBLIC_KEY_PATH"
  echo "❌ Пару ключів видалено. Запустіть скрипт знову і введіть непорожній passphrase." >&2
  exit 1
fi

echo "Готово: приватний ключ ${PRIVATE_KEY_PATH}, публічний ключ ${PUBLIC_KEY_PATH}" >&2

# Повертаємо 3 значення у stdout (по одному на рядок)
echo "$SSH_DIR"
echo "$PRIVATE_KEY_PATH"
echo "$PUBLIC_KEY_PATH"