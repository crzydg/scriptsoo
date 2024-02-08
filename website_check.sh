#!/bin/bash

# Überprüfen, ob eine URL als Parameter angegeben wurde
if [ "$#" -ne 1 ]; then
    echo "Verwendung: $0 <URL der Website>"
    exit 1
fi

# Ziel-Website aus dem Parameter
website_url=$1

# Einfacher Name der Website für die Ausgabedatei
website_name=$(echo $website_url | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/^https*:_//')

# Ausführen eines Curl-Befehls, um Header zu erhalten
headers=$(curl --head --silent $website_url)

# Aktuelles Datum und Uhrzeit
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

# Dateiname für den Bericht
report_file="${website_name}_security_report.html"

# Anfang des HTML-Berichts
echo "<html><head><title>Website Sicherheitsbericht $website_url</title></head><body>" > $report_file
echo "<h1>Website Sicherheitsbericht $website_url</h1>" >> $report_file
echo "<p>Datum & Uhrzeit des Tests: $current_datetime</p>" >> $report_file

# XSS-Schutz
csp_header=$(echo "$headers" | grep -i "Content-Security-Policy")
if [ ! -z "$csp_header" ]; then
    echo "<p>XSS-Schutz (Content-Security-Policy): <span style=\"color:green;\">Vorhanden</span> ($csp_header)</p>" >> $report_file
else
    echo "<p>XSS-Schutz (Content-Security-Policy): <span style=\"color:red;\">Nicht gefunden</span></p>" >> $report_file
fi

# Session Management
set_cookie_header=$(curl -sI $website_url | grep -i "Set-Cookie")
if echo "$set_cookie_header" | grep -qi 'secure'; then
    echo "<p>Session Management (Set-Cookie Header): <span style=\"color:green;\">Sicher</span> ($set_cookie_header)</p>" >> $report_file
else
    echo "<p>Session Management (Set-Cookie Header): <span style=\"color:red;\">Nicht sicher / Nicht gefunden</span></p>" >> $report_file
fi

#session_cookies=$(echo "$headers" | grep -i "Set-Cookie" | grep -Ei 'httponly|secure' || echo "Set-Cookie: Nicht sicher / Nicht gefunden")


# Ende des HTML-Berichts
echo "</body></html>" >> $report_file

echo "Sicherheitsbericht wurde erstellt: $report_file"

