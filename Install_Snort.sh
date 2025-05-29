#!/bin/bash

# ----------------------------------------
# Script de Instalación y Configuración Básica de Snort 2.9
# ----------------------------------------

echo "✅ Actualizando repositorios y sistema..."
sudo apt update && sudo apt upgrade -y

echo "✅ Instalando dependencias necesarias..."
sudo apt install -y build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev

echo "✅ Descargando Snort..."
wget https://www.snort.org/downloads/snort/snort-2.9.20.1.tar.gz -O snort.tar.gz

echo "✅ Extrayendo archivos..."
tar -xvzf snort.tar.gz
cd snort-2.9.20.1 || exit

echo "✅ Compilando e instalando Snort..."
./configure && make && sudo make install

echo "✅ Creando estructura de directorios..."
sudo mkdir -p /etc/snort/rules
sudo mkdir -p /var/log/snort
sudo mkdir -p /usr/local/lib/snort_dynamicrules

echo "✅ Copiando archivos de configuración por defecto..."
sudo cp -r etc/* /etc/snort/

echo "✅ Configurando snort.conf..."
sudo sed -i 's/^ipvar HOME_NET .*/ipvar HOME_NET 192.168.1.0\/24/' /etc/snort/snort.conf
grep -q 'include $RULE_PATH/local.rules' /etc/snort/snort.conf || echo 'include $RULE_PATH/local.rules' | sudo tee -a /etc/snort/snort.conf

echo "✅ Agregando regla ICMP personalizada..."
echo 'alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)' | sudo tee /etc/snort/rules/local.rules

echo "✅ Instalación completada."
echo "ℹ️ Para ejecutar Snort usa:"
echo "sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i <tu_interfaz>"
echo "Usa 'ip a' para ver tu interfaz (como eth0, ens33, enp0s3, etc.)"
