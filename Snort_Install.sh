#!/bin/bash

echo "📁 Respaldando /etc/apt/sources.list como sources.list.bak..."
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo "➕ Agregando repositorios de Ubuntu al final de /etc/apt/sources.list..."
sudo tee -a /etc/apt/sources.list > /dev/null <<EOF

# Repositorios Ubuntu focal (añadidos para instalar Snort)
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse
deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb [arch=i386,amd64] http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse
EOF

echo "🔑 Agregando claves GPG..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C

echo "🔄 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Snort desde APT..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y snort

echo "⏳ Esperando 5 segundos para continuar..."
sleep 5

# Verificación de archivos
CONF="/etc/snort/snort.conf"
RULES="/etc/snort/rules/local.rules"

echo "🔍 Verificando existencia de archivos..."
ls "$CONF" || { echo "❌ $CONF no existe. Revisa instalación."; exit 1; }
ls "$RULES" || { echo "❌ $RULES no existe. Creando archivo..."; sudo touch "$RULES"; }

# 2. Crear una regla ICMP
echo "📝 Agregando regla personalizada ICMP..."
RULE_ICMP='alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)'
if ! grep -q "Ping detectado" "$RULES"; then
  echo "$RULE_ICMP" | sudo tee -a "$RULES"
fi

# 3. Asegurar inclusión de local.rules
echo "🧩 Asegurando inclusión de local.rules en snort.conf..."
if ! grep -q "include \$RULE_PATH/local.rules" "$CONF"; then
  echo "include \$RULE_PATH/local.rules" | sudo tee -a "$CONF"
fi

# Pedir IP de red
read -p "🌐 Ingresa tu red interna (ej. 192.168.1.0/24): " HOME_NET
if grep -q "^ipvar HOME_NET" "$CONF"; then
  sudo sed -i "s|^ipvar HOME_NET .*|ipvar HOME_NET $HOME_NET|" "$CONF"
else
  echo "ipvar HOME_NET $HOME_NET" | sudo tee -a "$CONF"
fi

# Pedir interfaz de red
read -p "🔌 Ingresa el nombre de tu interfaz de red (ej. eth0, enp0s3): " INTERFAZ

# Ejecutar Snort
echo "🚀 Ejecutando Snort..."
sudo snort -A console -q -c /etc/snort/snort.conf -i "$INTERFAZ"
