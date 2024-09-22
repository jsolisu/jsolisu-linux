#!/bin/bash

# El token de autenticación de GitHub se pasa como argumento y debe tener scope "repo"
token=$1

# URL base de la API de GitHub para obtener los repositorios del usuario
url="https://api.github.com/user/repos"

# Página inicial
page=1

# Función para obtener repositorios de una página específica
get_repos() {
    curl -s -H "Authorization: token $token" "$url?page=$1&per_page=100"
}

# Obtener y procesar todas las páginas
while :; do
    # Obtener los repositorios de la página actual
    response=$(get_repos $page)

    # Si la respuesta está vacía, hemos llegado al final
    if [[ -z "$response" || "$response" =~ ^\[[^[:alnum:]]*\]$ ]]; then
        break
    fi

    # Filtrar los repositorios que no sean forks y obtener las URLs
    echo "$response" | grep -E '"fork": false' -B 10 | grep -E '"html_url":' | awk -F '"' '{print $4}'

    # Incrementar el número de página
    page=$((page + 1))
done
