#!/bin/bash

# Überprüfung, ob das Skript als Root ausgeführt wird
if [ "$EUID" -ne 0 ]
  then echo "Bitte als Root ausführen"
  exit
fi

# Überprüfung der Argumente
if [ "$#" -ne 2 ]; then
    echo "Verwendung: $0 zielserver port"
    exit 1
fi

ZIELSERVER=$1
PORT=$2
DATEINAME="/etc/xinetd.d/$ZIELSERVER"

# Erstellen der xinetd-Konfigurationsdatei
cat > $DATEINAME <<EOF
service $ZIELSERVER
{
    disable         = no
    type            = UNLISTED
    socket_type     = stream
    wait            = no
    user            = root
    redirect        = $ZIELSERVER $PORT
    port            = $PORT
}
EOF

# Neustarten von xinetd
systemctl restart xinetd

echo "xinetd-Konfiguration für $ZIELSERVER auf Port $PORT erstellt und Dienst neu gestartet."

