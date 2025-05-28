#!/bin/bash

# Script para desinstalar Snort y limpiar configuraciones personalizadas

echo "🧹 Desinstalando Snort..."
sudo apt remove --purge -y snort
sudo apt autoremove -y
sudo apt autoclean

echo "🗑️ Eliminando archivos de configuración de Snort..."
sudo rm -rf /etc/snort
sudo rm -rf /var/log/snort

echo "🧾 Limpiando entradas de repositorios de Snort..."

# Eliminar líneas específicas agregadas al sources.list
sudo sed -i '/http:\/\/ports.ubuntu.com\/ubuntu-ports focal/d' /etc/apt/sources.list
sudo sed -i '/http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal/d' /etc/apt/sources.list
sudo sed -i '/http:\/\/security.ubuntu.com\/ubuntu focal-security/d' /etc/apt/sources.list

echo "🗝️ Limpiando claves GPG relacionadas (si existen)..."
sudo apt-key del 3B4FE6ACC0B21F32 2>/dev/null
sudo apt-key del 871920D1991BC93C 2>/dev/null

echo "🔁 Actualizando lista de paquetes..."
sudo apt update

echo "✅ Snort y sus configuraciones han sido eliminadas del sistema."

