#!/bin/bash
  
echo "===== Listar los directorios que tienen un repositorio Git ubicado en el branch indicado ====="
echo ""

# Verifica si se proporcionó un nombre de rama
if [ -z "$1" ]; then
  echo "Uso: ./list_repo_branch.sh <nombre-de-rama>"
  exit 1
fi

branch=$1
found=false

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
      found=true
    fi
    # Regresa al directorio anterior
    cd ..
  fi
done

# Muestra un mensaje si no se encontró ningún repositorio en la rama especificada
if [ "$found" = false ]; then
  echo "No se encontró ningún repositorio en la rama [$branch]"
else
  echo ">>>>> Fin de la lista <<<<<"
fi
