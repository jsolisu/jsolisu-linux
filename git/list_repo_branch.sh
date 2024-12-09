#!/bin/bash

echo -e "===== Listar los directorios que tienen un repositorio Git ubicado en el branch indicado =====\n"

# Verifica si se proporcionó un nombre de rama
if [ -z "$1" ]; then
  echo "Uso: ./list_repo_branch.sh <nombre-de-rama>"
  exit 1
fi

branch=$1
found=false
dirs=()

# Encuentra todos los directorios que contienen un repositorio Git
for dir in $(find . -type d -name .git | sed 's|/\.git||'); do
  # Verifica si el repositorio está en la rama especificada
  if [ "$(git -C "$dir" rev-parse --abbrev-ref HEAD)" == "$branch" ]; then
    dirs+=("${dir#./}")
    found=true
  fi
done

# Ordena y muestra los directorios
if [ "$found" = false ]; then
  echo -e "No se encontró ningún repositorio en la rama [$branch]\n"
else
  IFS=$'\n' sorted_dirs=($(sort <<<"${dirs[*]}"))
  unset IFS

  echo -e ">>>>> Lista de directorios con repositorios en la rama [$branch] <<<<<\n"
  for dir in "${sorted_dirs[@]}"; do
    echo "$dir"
  done
  echo -e "\n>>>>> Fin de la lista <<<<<\n"
fi
