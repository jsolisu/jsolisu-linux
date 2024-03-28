#!/bin/bash

echo "Obteniendo repositorios. Por favor, espere..."
dirlist=$(find -type d \( -iname .git -print \) | sed 's/.\{5\}$//')
for dir in $dirlist; do
    (
        cd $dir

        echo -e "\e[31m\e[1mOptimizando \e[33m$dir\e[0m..."

        # sincronizar contra las ramas remotas
        git remote update origin --prune
        
        # quita las ramas que ya no existen remotamente, siempre que se hayan fusionado
        git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D

        # limpia el registro de referencias
        git reflog expire --all --expire=now

        # ejecuta el garbage collector
        git gc --prune=now --aggressive

        # quita los archivos que no estan bajo el control de versiones
        git clean -df
    )
done
