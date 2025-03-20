#!/bin/bash
rsync -av /etc/ /backup/etc_config/
echo "Respaldo completado: $(date)" >> /var/log/respaldo.log
