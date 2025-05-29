#!/bin/bash

# ----------------------------------------
# Instalación completa de DAQ y Snort 2.9.20 en Ubuntu Server
# ----------------------------------------

echo "✅ Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "✅ Instalando dependencias..."
sudo apt install -y \
  build-essential \
  libpcap-dev \
  libpcre3-dev \
  libdumbnet-dev \
  bison \
  flex \
  zlib1g-dev \
  liblzma-dev \
  openssl \
  libssl-dev \
  libnghttp2-dev \
  autotools-dev \
  libtool \
  autoconf

# Instalar DAQ
echo "📦 Desempaquetando e instalando DAQ..."
tar -xvzf daq-2.0.7.tar.gz
cd daq-2.0.7 || exit
./configure && make && sudo make install
cd ..

# Instalar Snort
echo "🐗 Desempaquetando e instalando Snort..."
tar -xvzf snort-2.9.20.tar.gz
cd snort-2.9.20 || exit
./configure && make && sudo make install
cd ..

# Crear estructura de directorios
echo "📁 Creando estructura de archivos para Snort..."
sudo mkdir -p /etc/snort/rules
sudo mkdir -p /var/log/snort
sudo mkdir -p /usr/local/lib/snort_dynamicrules

echo "📄 Copiando archivos de configuración..."
sudo cp -r snort-2.9.20/etc/* /etc/snort/

# Configurar snort.conf
echo "⚙️ Configurando snort.conf..."
sudo sed -i 's/^ipvar HOME_NET .*/ipvar HOME_NET 192.168.1.0\/24/' /etc/snort/snort.conf
grep -q 'include $RULE_PATH/local.rules' /etc/snort/snort.conf || echo 'include $RULE_PATH/local.rules' | sudo tee -a /etc/snort/snort.conf

# Crear regla ICMP de prueba
echo "🛡️ Creando regla ICMP personalizada..."
echo 'alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)' | sudo tee /etc/snort/rules/local.rules

# Final
echo "✅ Instalación completada correctamente."
echo "🔍 Usa 'ip a' para ver tu interfaz de red (ej: ens33, enp0s3, eth0)."
echo "➡️ Luego ejecuta Snort con:"
echo "sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i <tu_interfaz>"
