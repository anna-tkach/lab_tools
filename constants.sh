#!/bin/bash
# _tools/constants.sh

# Шлях до директорії із усіма проектами
LAB_ROOT_DIRECTORY=~/lab

# Список усіх паралельних гілок дерева у кореневій папці, які всі будуть мати однакову структуру для проектів та репозиторіїв.
# Але матимуть різний зміст, бо кожна із цих папок-гілок призначена для різного контенту.
# Гілка для всіх репозиторіїв, все що є "код" і попадає в гіт.
LAB_ROOT_DIRECTORY_BRANCH_REPOS=repos
# Гілка для всіх чутливих даних, якщо такі будуть. Якщо сюди щось попаде - воно має
# бути зашифроване.
LAB_ROOT_DIRECTORY_BRANCH_VAULT=vault
# Гілка для скриптів-ранерів безпечного середовища для репозиторіїв.
LAB_ROOT_DIRECTORY_BRANCH_RUNNERS=runners

# Всі гілки зібрані в 1 масив.
LAB_ROOT_DIRECTORY_BRANCHES=($LAB_ROOT_DIRECTORY_BRANCH_REPOS $LAB_ROOT_DIRECTORY_BRANCH_VAULT $LAB_ROOT_DIRECTORY_BRANCH_RUNNERS)