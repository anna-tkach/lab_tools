#!/bin/bash
# _tools/keys/ssh/generate/utils_paths_computing.sh
#

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# "$(dirname "$0")" — тека, де лежить цей скрипт
SCRIPT_DIR="$(dirname "$0")"

# Підключаємо константи рівня ssh (специфічні для SSH-ключів)
source "${SCRIPT_DIR}/../../constants.sh"
# Підключаємо константи рівня keys (спільні для всіх типів ключів)
source "${SCRIPT_DIR}/../../../constants.sh"

# Return 3 values:
# 1) ssh folder absolute path
# 2) ssh private key absolute path
# 3) ssh public key absolute path
compute_ssh_keys_paths() {
  # read input
  KEY_NAME="$1"
  VAULT_ABSOLUTE_PATH="$2"

  # build paths
  KEYS_ABSOLUTE_PATH="${VAULT_ABSOLUTE_PATH}/${KEYS_VAULT_FOLDER_NAME}"
  SSH_KEYS_ABSOLUTE_PATH="${KEYS_ABSOLUTE_PATH}/${SSH_VAULT_FOLDER_NAME}"
  PRIVATE_KEY_ABSOLUTE_PATH="${SSH_KEYS_ABSOLUTE_PATH}/${KEY_NAME}"
  PUBLIC_KEY_ABSOLUTE_PATH="${PRIVATE_KEY_ABSOLUTE_PATH}.pub"

  # return 3 values
  echo "$SSH_KEYS_ABSOLUTE_PATH";
  echo "$PRIVATE_KEY_ABSOLUTE_PATH";
  echo "$PUBLIC_KEY_ABSOLUTE_PATH";
}
