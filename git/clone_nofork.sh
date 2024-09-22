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

    # Si la respuesta contiene la cadena "DOCTYPE", hemos llegado al final y puede pasar por un error
    if [[ "$response" == *"DOCTYPE"* ]]; then
        break
    fi

    # Si la respuesta está vacía, hemos llegado al final
    if [[ -z "$response" || "$response" =~ ^\[[^[:alnum:]]*\]$ ]]; then
        break
    fi

    # Filtrar los repositorios que no sean forks y obtener los nombres y URLs
    names=$(echo "$response" | grep -E '"fork": false' -B 30 | grep -E '"name":' | awk -F '"' '{print $4}')
    urls=$(echo "$response" | grep -E '"fork": false' -B 10 | grep -E '"html_url":' | awk -F '"' '{print $4}')

    # Clonar los repositorios
    for name in $names; do
        url=$(echo "$urls" | sed -n "1p")
        urls=$(echo "$urls" | sed '1d')
        
        # Clonar solamente si el directorio $name no existe
        if [ ! -d "$name" ]; then
            echo "Clonando $name from $url"
            git clone "$url"
        fi
    done

    # Incrementar el número de página
    page=$((page + 1))
    
    # Esperar 2 segundos para evitar exceder el límite de la API
    sleep 2
done
