#!/bin/bash

echo "Obteniendo repositorios. Por favor, espere..."
dirlist=$(find -type d \( -iname .git -print \) | sed 's/.\{5\}$//')
for dir in $dirlist; do
    (
        cd $dir

        echo -e "\e[31m\e[1mOptimizando \e[33m$dir\e[0m..."
        git gc --aggressive
    )
done
