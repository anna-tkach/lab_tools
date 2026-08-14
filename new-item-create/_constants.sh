#!/bin/bash
# _tools/new-item-create/_constants.sh

# Шлях до директорії із усіма проектами
LAB_ROOT_DIRECTORY=~/lab

# Список усіх паралельних дерев у кореневій папці — єдине місце, де він визначений;
# owner.sh, project.sh і repos.sh використовують цей самий список замість
# трьох окремих захардкоджених копій
LAB_ROOT_DIRECTORY_BRANCH_REPOS=repos
LAB_ROOT_DIRECTORY_BRANCH_VAULT=vault
LAB_ROOT_DIRECTORY_BRANCH_RUNNERS=runners

LAB_ROOT_DIRECTORY_BRANCHES=($LAB_ROOT_DIRECTORY_BRANCH_REPOS $LAB_ROOT_DIRECTORY_BRANCH_VAULT $LAB_ROOT_DIRECTORY_BRANCH_RUNNERS)