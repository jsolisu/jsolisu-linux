#!/bin/bash

update="F"
parametros=("$@")

while [ -n "$1" ]; do
    case "$1" in
    -u) update="T" ;;
    *) if [ "$1" = -* ]; then
        echo "Opción $1 no reconocida."
    fi ;;
    esac
    shift
done

if [ "$update" = "F" ]; then
    branch="${parametros[0]}"
else
    branch="${parametros[1]}"
fi

if [ -z "$branch" ]; then
    branch="master"
fi

echo -e "Usando rama [\e[32m\e[1m$branch\e[0m]\n"

echo "Obteniendo repositorios. Por favor, espere..."
dirlist=$(find -type d \( -iname .git -print \) | sed 's/.\{5\}$//')
for dir in $dirlist; do
    (
        cd $dir

        echo -e "\e[31m\e[1mActualizando ramas \e[33m$dir\e[0m..."
        git fetch --all

        echo -e "\e[31m\e[1mDescartando cambios \e[33m$dir\e[0m..."
        git stash

        if git show-ref --quiet refs/heads/$branch; then
            git checkout $branch
        else
            default_branch=$(git remote show origin | grep HEAD | grep -oE '[^ ]+$')
            if [ ! -z "$default_branch" ]; then
                echo -e "Usando rama [\e[32m\e[1m$default_branch\e[0m], porque la rama [\e[32m\e[1m$branch\e[0m] no existe..."
                git checkout $default_branch
            else
                echo -e "Usando rama [\e[32m\e[1mmaster\e[0m], porque la rama [\e[32m\e[1m$branch\e[0m] no existe..."
                git checkout master
            fi
        fi

        git reset --hard HEAD
        if [ "$update" = "T" ]; then
            echo -e "\e[34m\e[1mActualizando \e[33m$dir\e[0m..."
            git pull
        fi
    )
done
