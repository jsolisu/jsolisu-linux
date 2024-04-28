#!/bin/bash

echo "Obteniendo repositorios. Por favor, espere..."
dirlist=$(find -type d \( -iname .git -print \) | sed 's/.\{5\}$//')
for dir in $dirlist; do
    (
        cd $dir

        echo -e "\e[31m\e[1mOptimizando \e[33m$dir\e[0m..."

        # sincronizar contra las ramas remotas
        echo -e "\e[32m\e[1mSincronizando ramas remotas\e[0m..."
        git remote update origin --prune
        
        # quita las ramas que ya no existen remotamente, siempre que se hayan fusionado
        echo -e "\e[32m\e[1mQuitando ramas que ya no existen remotamente\e[0m..."
        git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D

        # limpia el registro de referencias
        echo -e "\e[32m\e[1mLimpiando referencias\e[0m..."
        git reflog expire --all --expire=now

        # ejecuta el garbage collector
        echo -e "\e[32m\e[1mRecolectando basura\e[0m..."
        git gc --prune=now --aggressive

        # quita los archivos que no estan bajo el control de versiones
        echo -e "\e[32m\e[1mQuitando archivos fuera del control de versiones\e[0m..."
        git clean -df
    )
done
