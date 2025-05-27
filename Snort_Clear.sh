#!/bin/bash

echo "🧹 Desinstalación completa de Snort y limpieza del sistema..."

# Paso 1: Eliminar Snort
echo "➖ Eliminando Snort y archivos relacionados..."
sudo apt purge -y snort
sudo apt autoremove -y
sudo rm -rf /etc/snort
sudo rm -rf /var/log/snort
sudo rm -rf /usr/local/lib/snort_dynamicrules

# Paso 2: Restaurar sources.list
if [ -f /etc/apt/sources.list.bak ]; then
  echo "📝 Restaurando archivo /etc/apt/sources.list desde backup..."
  sudo cp /etc/apt/sources.list.bak /etc/apt/sources.list
else
  echo "⚠️ Backup de sources.list no encontrado. Limpieza manual de entradas Ubuntu..."

  # Eliminar líneas Ubuntu del sources.list actual
  sudo sed -i '/ubuntu-ports focal/d' /etc/apt/sources.list
  sudo sed -i '/us.archive.ubuntu.com.*focal/d' /etc/apt/sources.list
  sudo sed -i '/security.ubuntu.com.*focal/d' /etc/apt/sources.list
fi

# Paso 3: Eliminar claves GPG de Ubuntu si existen
echo "🔑 Limpiando claves GPG de Ubuntu..."
sudo apt-key del 3B4FE6ACC0B21F32 >/dev/null 2>&1
sudo apt-key del 871920D1991BC93C >/dev/null 2>&1

# Paso 4: Actualizar repositorios
echo "🔄 Ejecutando apt update..."
sudo apt update

echo "✅ Limpieza finalizada. Snort y sus configuraciones han sido eliminadas correctamente."
