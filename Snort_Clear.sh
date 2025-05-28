#!/bin/bash

# Script para desinstalar y limpiar Snort en Debian 12

echo "------------------------------------------------------------"
echo "  SCRIPT DE DESINSTALACIÓN Y LIMPIEZA DE SNORT"
echo "------------------------------------------------------------"
echo ""
echo "Este script detendrá y desinstalará los paquetes de Snort y realizará una limpieza."
echo "La eliminación de los repositorios de Ubuntu Focal y las claves GPG"
echo "requiere su intervención manual, ya que pueden afectar a otros paquetes."
echo ""

read -p "¿Estás seguro de que deseas desinstalar Snort y limpiar los paquetes? (s/N): " confirmacion
if [[ "$confirmacion" != "s" && "$confirmacion" != "S" ]]; then
    echo "Operación cancelada."
    exit 0
fi

echo "============================================================"
echo "  PASO 1: DETENIENDO EL SERVICIO DE SNORT (si está activo)"
echo "============================================================"
echo ""
sudo systemctl stop snort
echo "Servicio de Snort detenido (si estaba en ejecución)."
echo ""

echo "============================================================"
echo "  PASO 2: DESINSTALANDO PAQUETES DE SNORT"
echo "============================================================"
echo ""
echo "Desinstalando snort y snort-daq con 'apt purge'..."
sudo apt purge snort snort-daq -y
echo "Paquetes de Snort desinstalados."
echo ""

echo "============================================================"
echo "  PASO 3: LIMPIANDO CACHÉ DE PAQUETES Y DEPENDENCIAS"
echo "============================================================"
echo ""
echo "Ejecutando 'apt autoremove' para eliminar dependencias no usadas..."
sudo apt autoremove -y
echo "Dependencias no usadas eliminadas."
echo ""
echo "Limpiando el caché de paquetes de APT con 'apt clean'..."
sudo apt clean
echo "Caché de paquetes limpiado."
echo ""

echo "============================================================"
echo "  PASO 4: ELIMINACIÓN MANUAL DE REPOSITORIOS (RECOMENDADO)"
echo "============================================================"
echo ""
echo "Es ALTAMENTE RECOMENDADO eliminar las líneas de los repositorios de Ubuntu Focal"
echo "que agregaste en /etc/apt/sources.list si ya no los necesitas."
echo "Abriendo nano para que edites el archivo. Busca y elimina las líneas como:"
echo "  deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse"
echo "  deb [arch=i386,amd64] http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse"
echo "Guarda y cierra el archivo (Ctrl+O, Enter, Ctrl+X)."
read -p "Presiona Enter para abrir nano..."
sudo nano /etc/apt/sources.list

echo ""
echo "Actualizando los índices de paquetes después de modificar sources.list..."
sudo apt update
echo "Índices de paquetes actualizados."
echo ""

echo "============================================================"
echo "  PASO 5: ELIMINACIÓN MANUAL DE CLAVES GPG (OPCIONAL)"
echo "============================================================"
echo ""
echo "Puedes listar las claves GPG y eliminar las que agregaste para Snort si lo deseas."
echo "Esto es opcional y solo hazlo si estás seguro de que no afectará a otros repositorios."
echo "Las claves a buscar son: 3B4FE6ACC0B21F32 y 871920D1991BC93C"
read -p "Presiona Enter para listar las claves GPG (Ctrl+C para salir, luego puedes eliminarlas si quieres):"
sudo apt-key list
echo ""
echo "Para eliminar una clave (ejemplo): sudo apt-key del <ID_DE_LA_CLAVE>"
echo "Por ejemplo: sudo apt-key del 3B4FE6ACC0B21F32"
echo ""

echo "------------------------------------------------------------"
echo "  PROCESO DE DESINSTALACIÓN Y LIMPIEZA DE SNORT FINALIZADO"
echo "------------------------------------------------------------"
echo ""
echo "Snort y sus componentes principales han sido desinstalados."
echo "Recuerda que la eliminación de los repositorios y claves GPG depende de tu configuración y si los necesitas para otros fines."
