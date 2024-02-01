#!/bin/bash

# Definiere Grenzwerte
CPU_LIMIT=80  # CPU-Grenze in Prozent
MEM_LIMIT=500 # Speichergrenze in MB

# Apache Prozess-Name
APACHE_PROCESS_NAME='apache2' # oder 'httpd' auf RHEL Systemen

# Überprüfe Apache CPU- und Speichernutzung
APACHE_CPU_USAGE=$(ps -C $APACHE_PROCESS_NAME -o %cpu --no-headers | awk '{sum+=$1} END {print int(sum)}') # Umwandlung in ganze Zahl
APACHE_MEM_USAGE=$(ps -C $APACHE_PROCESS_NAME -o rss --no-headers | awk '{sum+=$1} END {print int(sum/1024)}') # Umwandlung in MB

# Prüfe, ob Grenzwerte überschritten werden
# use, if bc is not installed:
#if [ "$APACHE_CPU_USAGE" -gt "$CPU_LIMIT" ] || [ "$APACHE_MEM_USAGE" -gt "$MEM_LIMIT" ]; then
if (( $(echo "$APACHE_CPU_USAGE > $CPU_LIMIT" | bc -l) )) || [ "$APACHE_MEM_USAGE" -gt "$MEM_LIMIT" ]; then
    echo "Apache über Grenzwert. Neustart wird ausgeführt."
    systemctl restart apache2 # Verwenden Sie 'service apache2 restart' auf älteren Systemen
else
    echo "Apache innerhalb der Grenzwerte."
fi

