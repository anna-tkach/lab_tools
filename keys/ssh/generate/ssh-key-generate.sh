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
if [[ $# -ne 4 ]]; then
  echo "Використання: $0 <SSH_KEYS_ABSOLUTE_PATH> <SSH_PRIVATE_KEY_ABSOLUTE_PATH> <SSH_PUBLIC_KEY_ABSOLUTE_PATH> <EMAIL>" >&2
  exit 1
fi

SSH_KEYS_ABSOLUTE_PATH="$1"
SSH_PRIVATE_KEY_ABSOLUTE_PATH="$2"
SSH_PUBLIC_KEY_ABSOLUTE_PATH="$3"
EMAIL="$4"

echo  "ssh-key-generate.sh is called."
echo "$SSH_KEYS_ABSOLUTE_PATH"
echo "$SSH_PRIVATE_KEY_ABSOLUTE_PATH"
echo "$SSH_PUBLIC_KEY_ABSOLUTE_PATH"
echo "$EMAIL"

# Перевіряємо, чи вже існує приватний ключ саме за цим шляхом (вже з іменем)
if [[ -f "$SSH_PRIVATE_KEY_ABSOLUTE_PATH" ]]; then
  echo "SSH-ключ ${SSH_PRIVATE_KEY_ABSOLUTE_PATH} вже існує. Створення пропущено."
  exit 0
fi

# Створюємо директорію keys/ssh разом з батьківськими, якщо їх ще немає (mkdir -p ідемпотентний)
mkdir -p "$SSH_KEYS_ABSOLUTE_PATH"


echo "Створюємо новий SSH-ключ  ${SSH_PRIVATE_KEY_ABSOLUTE_PATH} з типом (${SSH_TYPE})"
echo "Зараз потрібно буде ввести passphrase (двічі) — приватний ключ буде зашифровано ним на диску."

# Генеруємо пару ключів; без -N, тому ssh-keygen сам інтерактивно запитає passphrase
ssh-keygen -t "$SSH_TYPE" -C "$EMAIL" -f "$SSH_PRIVATE_KEY_ABSOLUTE_PATH"

# Перевіряємо, чи можна прочитати приватний ключ з порожнім паролем — якщо так, значить passphrase не було введено
if ssh-keygen -y -P "" -f "$SSH_PRIVATE_KEY_ABSOLUTE_PATH" >/dev/null 2>&1; then
  echo "❌ Passphrase не було введено — приватний ключ лишився незашифрованим, що заборонено."
  # Видаляємо обидва файли пари, оскільки незашифрований ключ не відповідає вимогам безпеки
  rm -f "$SSH_PRIVATE_KEY_ABSOLUTE_PATH" "$SSH_PUBLIC_KEY_ABSOLUTE_PATH"
  echo "❌ Пару ключів видалено. Запустіть скрипт знову і введіть непорожній passphrase."
  exit 1
fi

echo "Готово: приватний ключ ${SSH_PRIVATE_KEY_ABSOLUTE_PATH}, публічний ключ ${SSH_PUBLIC_KEY_ABSOLUTE_PATH}"