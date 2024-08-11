#!/bin/bash

cleanup_deleted_branches() {
    current_branch=$(git symbolic-ref --short HEAD)
    branches_to_delete=$(git branch -vv | awk '/origin\/.*: gone]/ {print $1}')
    default_local_branch=$(git remote show origin | awk '/HEAD branch:/ {print $NF}')

    if [[ -n "$branches_to_delete" ]]; then
        if echo "$branches_to_delete" | grep -q "^$current_branch\$"; then
            echo "La rama actual ($current_branch) está en la lista de ramas para eliminar."

            if [[ "$current_branch" == "$default_local_branch" ]]; then
                echo "La rama actual es la rama por defecto local. Actualizando HEAD del remoto."

                git remote set-head origin --auto
                default_local_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's#refs/remotes/origin/##')

                if [[ -n "$default_local_branch" ]]; then
                    echo "Cambiando a la nueva rama por defecto local: $default_local_branch"
                    git checkout $default_local_branch

                    git branch -D $current_branch

                    branches_to_delete=$(git branch -vv | awk '/origin\/.*: gone]/ {print $1}')
                else
                    echo "No se pudo determinar la nueva rama por defecto local."
                    return 1
                fi
            else
                echo "La rama actual no es la rama por defecto local."

                if [[ -n "$default_local_branch" ]]; then
                    echo "Cambiando a la rama por defecto local: $default_local_branch"
                    git checkout $default_local_branch
                else
                    echo "No se pudo determinar la rama por defecto local."
                    return 1
                fi

                git branch -D $current_branch

                branches_to_delete=$(git branch -vv | awk '/origin\/.*: gone]/ {print $1}')
            fi
        fi

        # Elimina las ramas locales que han sido eliminadas en el remoto
        if [[ -n "$branches_to_delete" ]]; then
            echo "Eliminando ramas locales que han sido eliminadas en el remoto:"
            echo "$branches_to_delete" | xargs -r git branch -D
        else
            echo "No hay ramas locales para eliminar."
        fi
    else
        echo "No hay ramas locales para eliminar."
    fi
}

# Encuentra todos los directorios .git y cambia a sus directorios padres
find . -type d -name '.git' -exec dirname {} \; | while IFS= read -r dir; do
    if [ -d "$dir" ]; then
        cd "$dir" || {
            echo "No se pudo cambiar al directorio [$dir]."
            continue
        }

        echo -e "\e[31m\e[1mOptimizando \e[33m[$dir]\e[0m..."

        # Sincroniza las referencias locales con la información de del repositorio remoto
        echo -e "\e[32m\e[1mSincronizando ramas remotas\e[0m..."
        git remote update origin --prune

        # Elimina las ramas que ya no existen remotamente
        echo -e "\e[32m\e[1mQuitando ramas que ya no existen remotamente\e[0m..."
        cleanup_deleted_branches

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
            echo "No se pudo regresar al directorio original."
            exit 1
        }
    else
        echo "El directorio $dir no existe o no se puede acceder."
    fi
done
