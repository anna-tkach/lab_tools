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

# Обчислює шлях до файлу git-інструкції всередині вже відомої теки інструкцій.
# Працює однаково коректно як з абсолютним, так і з відносним шляхом до теки -
# просто дописує назву файлу в кінець. Цей модуль нічого не знає про назву чи
# розташування теки .instructions/ - це відповідальність викликача (top-level),
# який передає готовий шлях до теки.
#
# Аргументи:
#   1) REPO_INSTRUCTIONS_FOLDER_PATH - шлях (абсолютний або відносний) до теки інструкцій репозиторія
#
# Друкує (echo) один рядок - шлях до файлу git-інструкції (у тій самій формі - абсолютній
# чи відносній - що й вхідний шлях до теки).
compute_git_instruction_file_path_by_instructions_folder_path() {
  REPO_INSTRUCTIONS_FOLDER_PATH="$1"

  echo "${REPO_INSTRUCTIONS_FOLDER_PATH}/${SSH_GIT_CONNECT_INSTRUCTION_FILE_NAME}"
}

# Обернена операція до compute_git_instruction_file_path_by_instructions_folder_path() -
# відновлює шлях до теки інструкцій за шляхом до файлу git-інструкції, прибираючи
# з кінця відомий суфікс (назву файлу), а не покладаючись на "dirname" (dirname просто
# відрізає останній сегмент шляху, що виглядало б правильно навіть якби форма шляху
# колись змінилась, і замаскувало б помилку - тут же явно перевіряється, що шлях
# дійсно закінчується на очікуваний файл).
# Працює однаково коректно як з абсолютним, так і з відносним шляхом до файлу.
#
# Аргументи:
#   1) REPO_GIT_INSTRUCTION_FILE_PATH - шлях (абсолютний або відносний) до файлу git-інструкції
#
# Друкує (echo) один рядок - шлях до теки інструкцій, що містить цей файл (у тій самій
# формі - абсолютній чи відносній - що й вхідний шлях до файлу).
compute_instructions_folder_path_by_git_instruction_file_path() {
  REPO_GIT_INSTRUCTION_FILE_PATH="$1"

  local expected_suffix="/${SSH_GIT_CONNECT_INSTRUCTION_FILE_NAME}"
  if [[ "$REPO_GIT_INSTRUCTION_FILE_PATH" != *"$expected_suffix" ]]; then
    echo "Помилка: '$REPO_GIT_INSTRUCTION_FILE_PATH' не закінчується на '$expected_suffix'" >&2
    exit 1
  fi

  echo "${REPO_GIT_INSTRUCTION_FILE_PATH%$expected_suffix}"
}
