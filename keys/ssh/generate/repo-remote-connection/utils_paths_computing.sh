#!/bin/bash
# _tools/keys/ssh/generate/repo-remote-connection/utils_paths_computing.sh
#

# зупинити скрипт одразу, якщо будь-яка команда впаде з помилкою
set -euo pipefail

# Визначаємо директорію, в якій фізично лежить цей скрипт, щоб коректно
# підключити сусідні файли незалежно від того, звідки скрипт джерелується.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Підключаємо константи цього модуля (назва файлу git-інструкції)
source "${SCRIPT_DIR}/constants.sh"

# Обчислює абсолютний шлях до файлу git-інструкції всередині вже відомої теки інструкцій.
# Цей модуль нічого не знає про назву чи розташування теки .instructions/ - це
# відповідальність викликача (top-level), який передає готовий шлях до теки.
#
# Аргументи:
#   1) REPO_INSTRUCTIONS_FOLDER_ABSOLUTE_PATH - абсолютний шлях до теки інструкцій репозиторія
#
# Друкує (echo) один рядок - абсолютний шлях до файлу git-інструкції.
compute_git_instruction_file_absolute_path() {
  REPO_INSTRUCTIONS_FOLDER_ABSOLUTE_PATH="$1"

  echo "${REPO_INSTRUCTIONS_FOLDER_ABSOLUTE_PATH}/${SSH_GIT_CONNECT_INSTRUCTION_FILE_NAME}"
}
