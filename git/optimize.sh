#!/bin/bash

echo "Obteniendo repositorios. Por favor, espere..."
dirlist=$(find -type d \( -iname .git -print \) | sed 's/.\{5\}$//')
for dir in $dirlist; do
    (
        cd $dir

        echo -e "\e[31m\e[1mOptimizando \e[33m$dir\e[0m..."

        git remote update origin --prune
        git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
        git reflog expire --all --expire=now
        git gc --prune=now --aggressive
        git clean -ffdx
    )
done
