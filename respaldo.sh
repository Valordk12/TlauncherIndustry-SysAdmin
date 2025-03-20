#!/bin/bash

# Configuración
BACKUP_DIR="/backup/etc_config"
LOG_FILE="/var/log/respaldo.log"
BACKUP_FILE="respaldo-$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
LOCK_FILE="/tmp/respaldo.lock"
MAX_BACKUPS=7  # Número máximo de respaldos antes de eliminar los más antiguos

# Verifica si ya hay un respaldo en ejecución
if [ -f "$LOCK_FILE" ]; then
    echo "$(date) - ❌ Un respaldo ya está en ejecución." | tee -a "$LOG_FILE"
    exit 1
fi

# Crea un lock file para evitar múltiples ejecuciones
touch "$LOCK_FILE"

# Verifica que el directorio de respaldo exista, si no, lo crea
if [ ! -d "$BACKUP_DIR" ]; then
    echo "$(date) - 📂 Creando directorio de respaldo en $BACKUP_DIR" | tee -a "$LOG_FILE"
    mkdir -p "$BACKUP_DIR"
fi

# Verifica espacio en disco (mínimo 100MB)
ESPACIO_DISPONIBLE=$(df --output=avail "$BACKUP_DIR" | tail -n 1)
if [ "$ESPACIO_DISPONIBLE" -lt 100000 ]; then
    echo "$(date) - ⚠️ Espacio insuficiente para realizar el respaldo." | tee -a "$LOG_FILE"
    rm -f "$LOCK_FILE"
    exit 1
fi

# Realiza el respaldo y comprime
echo "$(date) - 🔄 Iniciando respaldo..." | tee -a "$LOG_FILE"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" /etc/

# Verifica si el respaldo fue exitoso
if [ $? -eq 0 ]; then
    echo "$(date) - ✅ Respaldo guardado en $BACKUP_DIR/$BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "$(date) - ❌ Error al crear el respaldo." | tee -a "$LOG_FILE"
fi

# Elimina respaldos antiguos si hay más de MAX_BACKUPS
NUM_RESPALDOS=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
if [ "$NUM_RESPALDOS" -gt "$MAX_BACKUPS" ]; then
    ARCHIVO_ANTIGUO=$(ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n 1)
    echo "$(date) - 🗑️ Eliminando respaldo antiguo: $ARCHIVO_ANTIGUO" | tee -a "$LOG_FILE"
    rm -f "$ARCHIVO_ANTIGUO"
fi

# Elimina el lock file
rm -f "$LOCK_FILE"

echo "$(date) - ✅ Respaldo finalizado correctamente." | tee -a "$LOG_FILE"

