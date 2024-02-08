#!/bin/bash

output="system_report.html"
hostname=$(hostname)
currentDateTime=$(date '+%Y-%m-%d %H:%M:%S')

# Start of the HTML Document
cat <<EOF > "$output"
<html>
<head>
    <title>System Report for $hostname</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h2 { color: #333; }
        pre { background-color: #f4f4f4; padding: 5px; border-left: 3px solid #333; }
    </style>
</head>
<body>
    <h1>System Report for $hostname</h1>
    <p>Report generated on $currentDateTime</p>
    <h2>Table of Contents</h2>
    <ul>
EOF

# Topics array
topics=("Linux Kernel Information" "Current User and ID information" "Linux Distribution Information"
        "List Current Logged In Users" "Uptime Information" "Running Services"
        "Active Internet Connections and Open Ports" "Check Available Space" "Check Memory"
        "History (Commands)" "Network Interfaces" "IPtable Information" "Check Running Processes"
        "Check SSH Configuration" "List all Packages Installed" "Network Parameters" "Password Policies"
        "Check your Source List File" "Check for Broken Dependencies" "MOTD banner message"
        "List User Names" "Check for Null Passwords" "IP Routing Table" "Kernel Messages"
        "Check Upgradable Packages" "CPU/System Information" "TCP wrappers" "Failed login attempts")

# Commands array
commands=("uname -a" "id" "cat /etc/*release" "who" "uptime" "systemctl list-units --type=service --state=running"
          "ss -tulwn" "df -h" "free -m" "history" "ip addr" "iptables -L" "ps aux"
          "cat /etc/ssh/sshd_config" "dpkg -l" "sysctl -a" "cat /etc/security/pwquality.conf"
          "cat /etc/apt/sources.list" "apt-get check" "cat /etc/motd" "cut -d: -f1 /etc/passwd"
          "awk -F: '(\$2 == \"\") {print \$1}' /etc/shadow" "netstat -rn" "dmesg | tail" "apt list --upgradable"
          "lscpu" "cat /etc/hosts.allow; cat /etc/hosts.deny" "grep 'Failed password' /var/log/auth.log")

# Generate TOC
for i in "${!topics[@]}"; do
    echo "        <li><a href='#section_$i'>${topics[$i]}</a></li>" >> "$output"
done

echo "    </ul>" >> "$output"

# Generate report content
for i in "${!topics[@]}"; do
    echo "<h2 id='section_$i'>${topics[$i]}</h2><pre>" >> "$output"
    eval "${commands[$i]}" >> "$output" 2>&1
    echo "</pre>" >> "$output"
done

# End of the HTML Document
echo "</body></html>" >> "$output"

echo "Report generated: $output"

