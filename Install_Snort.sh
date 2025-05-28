#!/bin/bash

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    sudo cp "$file" "${file}.backup.$(date +%Y%m%d%H%M%S)"
    echo "💾 Backup creado para $file"
  fi
}

echo "🔁 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "✅ Verificando repositorios en /etc/apt/sources.list..."
REPO_PATTERN="http://ports.ubuntu.com/ubuntu-ports focal"
if grep -q "$REPO_PATTERN" /etc/apt/sources.list; then
  echo "🔍 Repositorios ya presentes, no se agregan."
else
  echo "➕ Añadiendo repositorios a /etc/apt/sources.list..."
  sudo bash -c 'cat <<EOF >> /etc/apt/sources.list

deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse
deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb [arch=i386,amd64] http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse

EOF'
fi

echo "🔑 Registrando claves necesarias..."
KEY1="3B4FE6ACC0B21F32"
KEY2="871920D1991BC93C"

check_key() {
  sudo apt-key list | grep -q "$1"
}

if check_key "$KEY1"; then
  echo "🔍 Clave $KEY1 ya registrada."
else
  echo "➕ Registrando clave $KEY1..."
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$KEY1"
fi

if check_key "$KEY2"; then
  echo "🔍 Clave $KEY2 ya registrada."
else
  echo "➕ Registrando clave $KEY2..."
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$KEY2"
fi

echo "🔁 Actualizando sistema global nuevamente..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Snort si no está instalado..."
if dpkg -l | grep -qw snort; then
  echo "✅ Snort ya está instalado."
else
  sudo apt install -y snort
fi

echo "🔍 Validando archivos importantes..."

CONF_FILE="/etc/snort/snort.conf"
RULES_FILE="/etc/snort/rules/local.rules"

if [ -f "$CONF_FILE" ]; then
  echo "✅ Archivo encontrado: $CONF_FILE"
else
  echo "❌ Archivo NO encontrado: $CONF_FILE"
fi

if [ -f "$RULES_FILE" ]; then
  echo "✅ Archivo encontrado: $RULES_FILE"
else
  echo "❌ Archivo NO encontrado: $RULES_FILE"
fi

echo "📝 Insertando regla básica ICMP en local.rules..."
backup_file "$RULES_FILE"
# Evitar regla duplicada
if sudo grep -q 'alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)' "$RULES_FILE"; then
  echo "🔍 Regla ICMP ya existe en $RULES_FILE"
else
  sudo bash -c "echo 'alert icmp any any -> any any (msg:\"Ping detectado\"; sid:1000001; rev:1;)' >> $RULES_FILE"
  echo "➕ Regla ICMP agregada correctamente."
fi

read -p "🌐 Ingresa la red para HOME_NET (ej. 192.168.1.0/24): " IP

echo "⚙️ Configurando snort.conf..."
backup_file "$CONF_FILE"

if sudo grep -q 'include \$RULE_PATH/local.rules' "$CONF_FILE"; then
  echo "✅ local.rules ya está incluido en $CONF_FILE"
else
  echo "➕ Añadiendo inclusión de local.rules en $CONF_FILE..."
  sudo bash -c "echo 'include \$RULE_PATH/local.rules' >> $CONF_FILE"
fi

if sudo grep -q "^ipvar HOME_NET" "$CONF_FILE"; then
  sudo sed -i "s#^ipvar HOME_NET.*#ipvar HOME_NET $IP#" "$CONF_FILE"
  echo "✅ HOME_NET actualizado a $IP"
else
  sudo bash -c "echo 'ipvar HOME_NET $IP' >> $CONF_FILE"
  echo "✅ HOME_NET agregado como $IP"
fi

read -p "📡 Ingresa el nombre de la interfaz de red para Snort (ej. eth0, enp0s3): " INTERFAZ

echo "🚀 Ejecutando Snort en la interfaz $INTERFAZ..."
sudo snort -A console -q -c "$CONF_FILE" -i "$INTERFAZ"
