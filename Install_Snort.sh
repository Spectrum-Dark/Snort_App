#!/bin/bash

# ===============================
# INSTALADOR DE SNORT 2.9.20 EN UBUNTU SERVER
# Y PRUEBA DE PING ICMP
# ===============================

set -e

echo "[+] Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "[+] Instalando dependencias necesarias..."
sudo apt install -y build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev ethtool net-tools iputils-ping

echo "[+] Creando usuario y grupo para Snort..."
sudo groupadd -f snort
sudo id -u snort &>/dev/null || sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

echo "[+] Creando directorios necesarios..."
sudo mkdir -p /etc/snort/rules
sudo mkdir -p /var/log/snort
sudo mkdir -p /usr/local/lib/snort_dynamicrules
sudo touch /etc/snort/rules/white_list.rules
sudo touch /etc/snort/rules/black_list.rules
sudo chmod -R 5775 /etc/snort /var/log/snort
sudo chown -R snort:snort /etc/snort /var/log/snort

echo "[+] Descargando Snort 2.9.20..."
cd /tmp
wget https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz -O snort.tar.gz
tar -xvzf snort.tar.gz
cd snort-2.9.20

echo "[+] Compilando e instalando Snort..."
./configure --enable-sourcefire
make
sudo make install
sudo ldconfig

echo "[+] Copiando archivos de configuración base..."
sudo cp etc/*.conf* /etc/snort/

echo "[+] Configurando snort.conf..."
sudo sed -i 's/^ipvar HOME_NET .*/ipvar HOME_NET 192.168.1.0\/24/' /etc/snort/snort.conf
sudo sed -i 's@^var RULE_PATH .*@var RULE_PATH /etc/snort/rules@' /etc/snort/snort.conf
sudo sed -i 's@^var SO_RULE_PATH .*@var SO_RULE_PATH /usr/local/lib/snort_dynamicrules@' /etc/snort/snort.conf

echo "[+] Agregando regla personalizada para ICMP..."
echo 'alert icmp any any -> any any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)' | sudo tee /etc/snort/rules/icmp-ping.rules
echo 'include $RULE_PATH/icmp-ping.rules' | sudo tee -a /etc/snort/snort.conf

echo "[+] Detectando interfaz de red activa..."
INTERFAZ=$(ip route get 8.8.8.8 | grep -oP 'dev \K\S+')
echo "[+] Usando interfaz: $INTERFAZ"

echo "[+] Instalación completa. Ejecutando Snort en modo consola (presiona Ctrl+C para salir)..."
sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i $INTERFAZ
