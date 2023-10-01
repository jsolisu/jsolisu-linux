#!/bin/bash

rm -rf /tmp/$1

# paquetes
mkdir -p /tmp/$1
dpkg --get-selections > /tmp/$1/package.list

# repositorios
mkdir -p /tmp/$1/sources
sudo cp -R /etc/apt/sources.list* /tmp/$1/sources/

# llaves
sudo apt-key exportall > /tmp/$1/repo.keys

# perfil
mkdir -p /tmp/$1/personal_data
rsync --progress -arlp /home/`whoami` /tmp/$1/personal_data

cd /tmp
tar -czvpf $1.tar.gz /tmp/$1

sudo rm -rf $1