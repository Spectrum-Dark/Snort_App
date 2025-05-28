#!/bin/bash

# Script de automatización para la instalación y configuración básica de Snort en Debian 12

echo "------------------------------------------------------------"
echo "  SCRIPT DE INSTALACIÓN Y CONFIGURACIÓN BÁSICA DE SNORT"
echo "------------------------------------------------------------"
echo ""
echo "Este script automatiza los comandos directos para la instalación de Snort."
echo "Algunos pasos requieren tu intervención manual, como la edición de archivos."
echo "Por favor, lee cuidadosamente las instrucciones."
echo ""

# --- SECCIÓN 1: ACTUALIZACIÓN DE REPOSITORIOS Y INSTALACIÓN DE SNORT ---

echo "============================================================"
echo "  PASO 1: ACTUALIZACIÓN DE REPOSITORIOS Y INSTALACIÓN DE SNORT"
echo "============================================================"
echo ""

echo "1.1. Edición del archivo /etc/apt/sources.list (REQUIERE INTERVENCIÓN MANUAL)"
echo "    Abriendo nano para editar /etc/apt/sources.list."
echo "    POR FAVOR, AGREGA LAS SIGUIENTES LÍNEAS AL FINAL DEL ARCHIVO:"
echo ""
echo "    deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse"
echo "    deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse"
echo "    deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse"
echo "    deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse"
echo "    deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse"
echo "    deb [arch=i386,amd64] http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse"
echo ""
echo "    Guarda y cierra el archivo (Ctrl+O, Enter, Ctrl+X) después de agregar las líneas."
read -p "Presiona Enter para abrir nano..."
sudo nano /etc/apt/sources.list

echo ""
echo "1.2. Agregando las claves GPG necesarias..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C
echo "Claves GPG agregadas."
echo ""

echo "1.3. Actualizando los índices de paquetes..."
sudo apt update
echo "Índices de paquetes actualizados."
echo ""

echo "1.4. Instalando Snort..."
sudo apt install snort
echo "Snort instalado."
echo ""

echo "1.5. Verificando que los archivos de configuración existan..."
ls /etc/snort/snort.conf
ls /etc/snort/rules/local.rules
echo "Verificación de archivos de configuración completada."
echo ""

# --- SECCIÓN 2: CREAR UNA REGLA PERSONALIZADA ---

echo "============================================================"
echo "  PASO 2: CREAR UNA REGLA PERSONALIZADA"
echo "============================================================"
echo ""

echo "2.1. Edición del archivo local.rules para agregar una regla de ping (REQUIERE INTERVENCIÓN MANUAL)"
echo "    Abriendo nano para editar /etc/snort/rules/local.rules."
echo "    POR FAVOR, AGREGA LA SIGUIENTE REGLA AL FINAL DEL ARCHIVO:"
echo ""
echo '    alert icmp any any -> any any (msg:"Ping detectado"; sid:1000001; rev:1;)'
echo ""
echo "    Guarda y cierra el archivo (Ctrl+O, Enter, Ctrl+X) después de agregar la regla."
read -p "Presiona Enter para abrir nano..."
sudo nano /etc/snort/rules/local.rules

echo ""

# --- SECCIÓN 3: ASEGURARSE DE QUE snort.conf INCLUYA local.rules ---

echo "============================================================"
echo "  PASO 3: ASEGURARSE DE QUE snort.conf INCLUYA local.rules"
echo "============================================================"
echo ""

echo "3.1. Edición del archivo de configuración principal de Snort (REQUIERE INTERVENCIÓN MANUAL)"
echo "    Abriendo nano para editar /etc/snort/snort.conf."
echo "    POR FAVOR, ASEGÚRATE DE QUE LA SIGUIENTE LÍNEA ESTÉ PRESENTE (generalmente al final):"
echo ""
echo "    include \$RULE_PATH/local.rules"
echo ""
echo "    Y AJUSTA LA VARIABLE HOME_NET AL INICIO DEL ARCHIVO (ej. ipvar HOME_NET 192.168.1.0/24):"
echo ""
echo "    ipvar HOME_NET 192.168.1.0/24"
echo ""
echo "    Guarda y cierra el archivo (Ctrl+O, Enter, Ctrl+X) después de realizar los cambios."
read -p "Presiona Enter para abrir nano..."
sudo nano /etc/snort/snort.conf

echo ""

# --- SECCIÓN 4: VERIFICAR TU INTERFAZ DE RED ---

echo "============================================================"
echo "  PASO 4: VERIFICAR TU INTERFAZ DE RED"
echo "============================================================"
echo ""

echo "4.1. Listando interfaces de red..."
ip a
echo ""
echo "    POR FAVOR, IDENTIFICA TU INTERFAZ DE RED ACTIVA (ej. eth0, enp0s3, wlan0, etc.)."
read -p "Ingresa el nombre de tu interfaz de red (ej. eth0): " INTERFACE_SNORT
echo "Interfaz seleccionada: $INTERFACE_SNORT"
echo ""

# --- SECCIÓN 5: EJECUTAR SNORT ---

echo "============================================================"
echo "  PASO 5: EJECUTAR SNORT"
echo "============================================================"
echo ""

echo "5.1. Ejecutando Snort en modo consola con la interfaz seleccionada..."
echo "    Para detener Snort, presiona Ctrl+C."
echo "    Si hay errores de configuración, Snort los reportará aquí."
echo ""
sudo snort -A console -q -c /etc/snort/snort.conf -i "$INTERFACE_SNORT"

echo ""
echo "------------------------------------------------------------"
echo "  PROCESO DE CONFIGURACIÓN DE SNORT FINALIZADO"
echo "------------------------------------------------------------"