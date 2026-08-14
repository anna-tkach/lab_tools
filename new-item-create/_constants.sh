#!/bin/bash
# _tools/new-item-create/_constants.sh

# Шлях до директорії із усіма проектами
ROOT_DIRECTORY=~/lab

# Список усіх паралельних дерев у кореневій папці — єдине місце, де він визначений;
# owner.sh, project.sh і repos.sh використовують цей самий список замість
# трьох окремих захардкоджених копій
TREES=(repos vault runners)