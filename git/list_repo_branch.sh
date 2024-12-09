#!/bin/bash

# Verifica si se proporcionó un nombre de rama
if [ -z "$1" ]; then
  echo "Uso: ./list_repo_branch.sh <nombre-de-rama>"
  exit 1
fi

branch=$1

# Recorre todos los directorios en el directorio actual
for dir in */; do
  # Verifica si el directorio contiene un repositorio Git
  if [ -d "$dir/.git" ]; then
    # Cambia al directorio
    cd "$dir"
    # Verifica si el repositorio está en la rama especificada
    if [ "$(git rev-parse --abbrev-ref HEAD)" == "$branch" ]; then
      # Imprime el nombre del directorio sin la diagonal al final
      echo "${dir%/}"
    fi
    # Regresa al directorio anterior
    cd ..
  fi
done