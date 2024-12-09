#!/bin/bash

echo -e "===== Listar los directorios que tienen un repositorio Git ubicado en el branch indicado =====\n"

# Verifica si se proporcionó un nombre de rama
if [ -z "$1" ]; then
  echo "Uso: ./list_repo_branch.sh <nombre-de-rama>"
  exit 1
fi

branch=$1
found=false

# Encuentra todos los directorios que contienen un repositorio Git
for dir in $(find . -type d -name .git | sed 's|/\.git||'); do
  # Verifica si el repositorio está en la rama especificada
  if [ "$(git -C "$dir" rev-parse --abbrev-ref HEAD)" == "$branch" ]; then
    # Imprime el nombre del directorio sin la diagonal al final
    echo "${dir#./}"
    found=true
  fi
done

# Muestra un mensaje si no se encontró ningún repositorio en la rama especificada
if [ "$found" = false ]; then
  echo -e "No se encontró ningún repositorio en la rama [$branch]\n"
else
  echo -e ">>>>> Fin de la lista <<<<<\n"
fi
