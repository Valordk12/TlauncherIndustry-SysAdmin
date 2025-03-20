#!/bin/bash

# Ruta donde se guardan los respaldos de configuraciones
BACKUP_DIR="/backup/etc_config"

# Directorio de destino para restaurar las configuraciones
DEST_DIR="/etc"

# Función para restaurar un archivo específico
restore_file() {
    local FILE=$1
    echo "Restaurando $FILE..."
    
    # Comprobar si el archivo de respaldo existe
    if [[ -f "$BACKUP_DIR/$FILE" ]]; then
        cp "$BACKUP_DIR/$FILE" "$DEST_DIR/$FILE"
        echo "$FILE restaurado correctamente."
    else
        echo "Error: El archivo de respaldo $FILE no existe."
    fi
}

# Función principal para restaurar múltiples archivos
restore_all() {
    # Lista de archivos clave para restaurar
    local FILES=("db_config.conf" "httpd.conf" "my.cnf")

    # Iterar sobre la lista de archivos y restaurarlos
    for FILE in "${FILES[@]}"; do
        restore_file "$FILE"
    done
}

# Comprobar si el directorio de respaldo existe
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: El directorio de respaldo $BACKUP_DIR no existe."
    exit 1
fi

# Iniciar la restauración de configuraciones
echo "Iniciando restauración de configuraciones..."
restore_all
echo "Restauración completada."
