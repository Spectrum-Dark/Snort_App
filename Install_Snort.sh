#!/bin/bash

# Script para automatizar tareas básicas en Linux con Snort

echo "🔁 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "✅ Añadiendo repositorios a /etc/apt/sources.list..."
sudo bash -c 'cat <<EOF >> /etc/apt/sources.list

deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal main restricted universe multiverse
deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal-updates main restricted universe multiverse
deb [arch=arm64] [http://ports.ubuntu.com/ubuntu-ports](http://ports.ubuntu.com/ubuntu-ports) focal-security main restricted universe multiverse
deb [arch=i386,amd64] [http://us.archive.ubuntu.com/ubuntu/](http://us.archive.ubuntu.com/ubuntu/) focal main restricted universe multiverse
deb [arch=i386,amd64] [http://us.archive.ubuntu.com/ubuntu/](http://us.archive.ubuntu.com/ubuntu/) focal-updates main restricted universe multiverse
deb [arch=i386,amd64] [http://security.ubuntu.com/ubuntu](http://security.ubuntu.com/ubuntu) focal-security main restricted universe multiverse

EOF'

echo "🔑 Registrando claves necesarias..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C

echo "🔁 Actualizando sistema global nuevamente..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Snort..."
sudo apt install -y snort

echo "🔍 Validando archivos importantes..."

if [ -f /etc/snort/snort.conf ]; then
    echo "✅ Archivo encontrado: /etc/snort/snort.conf"
else
    echo "❌ Archivo NO encontrado: /etc/snort/snort.conf"
fi

if [ -f /etc/snort/rules/local.rules ]; then
    echo "✅ Archivo encontrado: /etc/snort/rules/local.rules"
else
    echo "❌ Archivo NO encontrado: /etc/snort/rules/local.rules"
fi

echo "📝 Insertando regla básica ICMP en local.rules..."
sudo bash -c 'echo "alert icmp any any -> any any (msg:\"Ping detectado\"; sid:1000001; rev:1;)" >> /etc/snort/rules/local.rules'

read -p "🌐 Ingresa la red para HOME_NET (ej. 192.168.1.0/24): " IP

echo "⚙️ Configurando snort.conf..."

if sudo grep -q 'include \$RULE_PATH/local.rules' /etc/snort/snort.conf; then
    echo "✅ local.rules ya está incluido en snort.conf"
else
    echo "➕ Añadiendo inclusión de local.rules en snort.conf..."
    sudo bash -c 'echo "include \$RULE_PATH/local.rules" >> /etc/snort/snort.conf'
fi

if sudo grep -q "^ipvar HOME_NET" /etc/snort/snort.conf; then
    sudo sed -i "s#^ipvar HOME_NET.*#ipvar HOME_NET $IP#" /etc/snort/snort.conf
    echo "✅ HOME_NET actualizado a $IP"
else
    sudo bash -c "echo 'ipvar HOME_NET $IP' >> /etc/snort/snort.conf"
    echo "✅ HOME_NET agregado como $IP"
fi

echo "✅ Instalación y configuración completada con éxito 😈​"
