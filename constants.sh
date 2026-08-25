#!/bin/bash
# _tools/constants.sh


# include vars from .env file.
[ -f "$(dirname "${BASH_SOURCE[0]}")/.env" ] && source "$(dirname "${BASH_SOURCE[0]}")/.env"

# Шлях до директорії із усіма проектами (беремо з .env або ставимо дефолтне значення)
LAB_ROOT_DIRECTORY="${LAB_ROOT_DIRECTORY:-~/lab}"

# Default git user name. Needed because each repo has own $HOME with own .gitconfig.
LAB_GIT_USER_NAME="${LAB_GIT_USER_NAME:-gitusername}"

# Список усіх паралельних гілок дерева у кореневій папці, які всі будуть мати однакову структуру для проектів та репозиторіїв.
# Але матимуть різний зміст, бо кожна із цих папок-гілок призначена для різного контенту.
# Гілка для всіх репозиторіїв, все що є "код" і попадає в гіт.
LAB_ROOT_DIRECTORY_BRANCH_REPO=repo
# Гілка для всіх чутливих даних, якщо такі будуть. Якщо сюди щось попаде - воно має
# бути зашифроване.
# При стовренні репозиторію тут буде одразу створюватися новий зашифрований ssh ключ.
LAB_ROOT_DIRECTORY_BRANCH_VAULT=vault
# Гілка для скриптів-ранерів безпечного середовища для репозиторіїв.
LAB_ROOT_DIRECTORY_BRANCH_RUNNERS=runners

# Всі гілки зібрані в 1 масив.
LAB_ROOT_DIRECTORY_BRANCHES=($LAB_ROOT_DIRECTORY_BRANCH_REPO $LAB_ROOT_DIRECTORY_BRANCH_VAULT $LAB_ROOT_DIRECTORY_BRANCH_RUNNERS)

# Take all PATHS from .env to build sandbox paths
REPO_RUNNER_VAR_PATH="${PATH_PYTHON3}:${PATH_RUBY}:${PATH_LOCAL_BIN}:${PATH_NVM_NODE_BIN}:${PATH_HOMEBREW_BIN}:${PATH_HOMEBREW_SBIN}:/usr/bin:/bin"