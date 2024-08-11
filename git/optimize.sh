#!/bin/bash

# Encuentra todos los directorios .git y cambia a sus directorios padres
find . -type d -name '.git' -exec dirname {} \; | while IFS= read -r dir; do
    if [ -d "$dir" ]; then
        cd "$dir" || {
            echo "No se pudo cambiar al directorio $dir"
            continue
        }

        echo -e "\e[31m\e[1mOptimizando \e[33m$dir\e[0m..."

        # Sincroniza las referencias locales con la información de del repositorio remoto
        echo -e "\e[32m\e[1mSincronizando ramas remotas\e[0m..."
        git remote update origin --prune

        # Elimina las ramas que ya no existen remotamente
        echo -e "\e[32m\e[1mQuitando ramas que ya no existen remotamente\e[0m..."
        git branch -vv | awk '/origin\/.*: gone]/ {print $1}' | xargs -r git branch -D

        # Limpia el registro de referencias
        echo -e "\e[32m\e[1mLimpiando referencias\e[0m..."
        git reflog expire --all --expire=now

        # Ejecuta el garbage collector
        echo -e "\e[32m\e[1mRecolectando basura\e[0m..."
        git gc --prune=now --aggressive

        # Elimina archivos que no están bajo el control de versiones
        echo -e "\e[32m\e[1mQuitando archivos fuera del control de versiones\e[0m..."
        git clean -df

        # Regresa al directorio original
        cd - >/dev/null || {
            echo "No se pudo regresar al directorio original"
            exit 1
        }
    else
        echo "El directorio $dir no existe o no se puede acceder"
    fi
done
