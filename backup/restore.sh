#!/bin/bash

# perfil
rsync --progress -arlp /tmp/$1/personal_data /home/`whoami`

# llaves
sudo apt-key add /tmp/$1/repo.keys

# repositorios
sudo cp -R /tmp/$1/sources/sources.list* /etc/apt/

# paquetes
sudo apt-get update
sudo apt-get install dselect
sudo dselect update
sudo dpkg --set-selections < /tmp/$1/package.list
sudo apt-get dselect-upgrade -y