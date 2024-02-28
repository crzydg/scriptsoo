#!/bin/bash

function rhel() {
    yum -q check-update | while read i; do
        i=$(echo $i)
        if [ "${i}x" != "x" ]; then
            UVERSION=${i#*\ }
            UVERSION=${UVERSION%\ *}
            PNAME=${i%%\ *}
            PNAME=${PNAME%.*}
            echo $(rpm -q "${PNAME}" --qf '"%{NAME}","%{VERSION}","')${UVERSION}\"
        fi
    done
}

function debian() {
    apt list --upgradable | awk -F'[/ ]' -v OFS=',' 'NR>1 {gsub(/\]/, "", $7); print "\"" $1 "\"", "\"" $7 "\"", "\"" $3 "\""}'
}

function sles() {
    sudo zypper list-updates | awk -F "|" 'NR>2 && NF>1 {gsub(/^[ \t]+|[ \t]+$/, "", $3); gsub(/^[ \t]+|[ \t]+$/, "", $4); gsub(/^[ \t]+|[ \t]+$/, "", $5); print "\"" $3 "\",\"" $4 "\",\"" $5 "\""}'
}


# Check for RHEL
if which yum >/dev/null 2>&1; then
        echo "Name,Installed,Update" > /tmp/$(hostname -s)_packages.csv
    rhel >> /tmp/$(hostname -s)_packages.csv
# Check for Debian
elif which apt >/dev/null 2>&1; then
        echo "Name,Installed,Update" > /tmp/$(hostname -s)_packages.csv
    debian >> /tmp/$(hostname -s)_packages.csv
# Check for SLES
elif which zypper >/dev/null 2>&1; then
        echo "Name,Installed,Update" > /tmp/$(hostname -s)_packages.csv
    sles >> packages.csv
else
    echo "Unknown package manager"
fi

