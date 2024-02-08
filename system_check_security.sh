#!/bin/bash

# Output file
LOGFILE="/tmp/$(hostname)_scan_report.html"

# Function to generate HTML table rows
function generate_html_row {
  echo "<tr><td>$1</td><td>$2</td></tr>"
}

# Function to generate TOC entry
function generate_toc_entry {
  echo "<li><a href=\"#section_$1\">$2</a></li>"
}

# Function to remove comments from sshd_config and output one line at a time
function format_sshd_config {
  grep -Ev '^\s*#|^$' /etc/ssh/sshd_config | while read -r line; do
    echo "$line <br>"
  done
}

# Start building the HTML output
cat <<EOL > "$LOGFILE"
<!DOCTYPE html>
<html>
<head>
  <title>Server Scan Report</title>
</head>
<body>
  <h1>Server Scan Report</h1>
  <p>Current Date and Time: $(date)</p>
  <p>Server Name: $(hostname)</p>

  <h2>Table of Contents</h2>
  <ul>
    $(generate_toc_entry 0 "0. Scan Server for Listening Ports")
    $(generate_toc_entry 1 "1. sshd_config")
    $(generate_toc_entry 2 "2. User home directories")
    $(generate_toc_entry 3 "2a. .ssh directory permissions")
    $(generate_toc_entry 4 "3. SUID files")
    $(generate_toc_entry 5 "4. System Information")
    $(generate_toc_entry 6 "5. Stack Protection")
    $(generate_toc_entry 7 "6. Security Settings")
    $(generate_toc_entry 8 "7. Checking accounts for empty passwords")
    $(generate_toc_entry 9 "8. FTP Server Settings")
  </ul>

  <h2>Results</h2>
EOL

# Check 0: Scan Server for Listening Ports
echo "<h3 id=\"section_0\">0. Scan Server for Listening Ports</h3>" >> "$LOGFILE"
listening_ports=$(netstat -tulpen 2>/dev/null || ss -tulpen 2>/dev/null)
if [[ -n "$listening_ports" ]]; then
  echo "<p>Listening Ports:</p>" >> "$LOGFILE"
  echo "<pre>$listening_ports</pre>" >> "$LOGFILE"

  # Check 1: sshd_config
  echo "<h3 id=\"section_1\">1. sshd_config</h3>" >> "$LOGFILE"
  generate_html_row "1. sshd_config (One Line at a Time)" "$(format_sshd_config)" >> "$LOGFILE"

  # Check 2: User home directories
  echo "<h3 id=\"section_2\">2. User home directories</h3>" >> "$LOGFILE"
  echo "<p><strong>List of User Home Directories:</strong></p>" >> "$LOGFILE"
  for directory in $(getent passwd | awk -F: '{print $6}'); do
    permissions=$(stat -c '%a' "$directory")
    echo "<p>$directory (Permissions: <strong>$permissions</strong>)</p>" >> "$LOGFILE"
  done

  # Check 2a: .ssh directory permissions
  echo "<h3 id=\"section_3\">2a. .ssh directory permissions</h3>" >> "$LOGFILE"
  echo "<p><strong>.ssh Directory Permissions:</strong></p>" >> "$LOGFILE"
  find /home -type d -name '.ssh' -exec stat -c '%n %a' {} \; | while read -r line; do
    echo "<p>$line</p>" >> "$LOGFILE"
  done

  # Check 3: SUID files
  echo "<h3 id=\"section_4\">3. SUID files</h3>" >> "$LOGFILE"
  generate_html_row "3. SUID files" "$(find / \( -path "/mnt*" -o -path "/proc*" -o -path "/sys*" -o -path "/run*" -o -path "/dev*" -o -path "/lost+found*" \) -prune -o -type f -perm /6000 -print)" >> "$LOGFILE"

  # Check 4: System information
  echo "<h3 id=\"section_5\">4. System Information</h3>" >> "$LOGFILE"
  generate_html_row "4. System Information" "Patchlevel: $(uname -r) <br> Last Reboot: $(who -b | awk '{print $3, $4}') <br> Packages for Update: $(apt list --upgradable 2>/dev/null)" >> "$LOGFILE"

  # Check 5: Stack Protection
  echo "<h3 id=\"section_6\">5. Stack Protection</h3>" >> "$LOGFILE"
  generate_html_row "5. Stack Protection" "$(grep -E '^\s*kernel\.randomize_va_space\s*=\s*2' /etc/sysctl.conf)" >> "$LOGFILE"

  # Check 6: Security Settings
  echo "<h3 id=\"section_7\">6. Security Settings</h3>" >> "$LOGFILE"
  security_settings_output=""
  security_settings_output+="<strong>SYN-Cookies:</strong> \$(cat /proc/sys/net/ipv4/tcp_syncookies 2> /dev/null) (Current Setting) # Command to set: echo 1 > /proc/sys/net/ipv4/tcp_syncookies 2> /dev/null <br>"
  security_settings_output+="<strong>Stop Source-Routing:</strong> \$(cat /proc/sys/net/ipv4/conf/*/accept_source_route 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 0 > \$i/accept_source_route 2> /dev/null; done <br>"
  security_settings_output+="<strong>Stop Redirecting:</strong> \$(cat /proc/sys/net/ipv4/conf/*/accept_redirects 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 0 > \$i/accept_redirects 2> /dev/null; done <br>"
  security_settings_output+="<strong>Reverse-Path-Filter:</strong> \$(cat /proc/sys/net/ipv4/conf/*/rp_filter 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 2 > \$i/rp_filter 2> /dev/null; done <br>"
  security_settings_output+="<strong>Log Martians:</strong> \$(cat /proc/sys/net/ipv4/conf/*/log_martians 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 1 > \$i/log_martians 2> /dev/null; done <br>"
  security_settings_output+="<strong>BOOTP-Relaying:</strong> \$(cat /proc/sys/net/ipv4/conf/*/bootp_relay 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 0 > \$i/bootp_relay 2> /dev/null; done <br>"
  security_settings_output+="<strong>Proxy-ARP:</strong> \$(cat /proc/sys/net/ipv4/conf/*/proxy_arp 2> /dev/null | head -n 1) (Current Setting) # Command to set: for i in /proc/sys/net/ipv4/conf/*; do echo 0 > \$i/proxy_arp 2> /dev/null; done <br>"
  security_settings_output+="<strong>ICMP Ignore Bogus Error Responses:</strong> \$(cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses 2> /dev/null) (Current Setting) # Command to set: echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses 2> /dev/null <br>"
  security_settings_output+="<strong>ICMP Echo Ignore Broadcasts:</strong> \$(cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 2> /dev/null) (Current Setting) # Command to set: echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 2> /dev/null <br>"
  security_settings_output+="<strong>ICMP Rate Limit:</strong> \$(cat /proc/sys/net/ipv4/icmp_ratelimit 2> /dev/null) (Current Setting) # Command to set: echo 5 > /proc/sys/net/ipv4/icmp_ratelimit <br>"
  security_settings_output+="<strong>IP Fragmentation High Threshold:</strong> \$(cat /proc/sys/net/ipv4/ipfrag_high_thresh 2> /dev/null) (Current Setting) # Command to set: echo 262144 > /proc/sys/net/ipv4/ipfrag_high_thresh <br>"
  security_settings_output+="<strong>IP Fragmentation Low Threshold:</strong> \$(cat /proc/sys/net/ipv4/ipfrag_low_thresh 2> /dev/null) (Current Setting) # Command to set: echo 196608 > /proc/sys/net/ipv4/ipfrag_low_thresh <br>"
  security_settings_output+="<strong>IP Fragmentation Time:</strong> \$(cat /proc/sys/net/ipv4/ipfrag_time 2> /dev/null) (Current Setting) # Command to set: echo 30 > /proc/sys/net/ipv4/ipfrag_time <br>"
  security_settings_output+="<strong>TCP FIN Timeout:</strong> \$(cat /proc/sys/net/ipv4/tcp_fin_timeout 2> /dev/null) (Current Setting) # Command to set: echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout <br>"
  security_settings_output+="<strong>TCP Retries1:</strong> \$(cat /proc/sys/net/ipv4/tcp_retries1 2> /dev/null) (Current Setting) # Command to set: echo 3 > /proc/sys/net/ipv4/tcp_retries1 <br>"
  security_settings_output+="<strong>TCP Retries2:</strong> \$(cat /proc/sys/net/ipv4/tcp_retries2 2> /dev/null) (Current Setting) # Command to set: echo 15 > /proc/sys/net/ipv4/tcp_retries2 <br>"

  echo "<p>$security_settings_output</p>" >> "$LOGFILE"

  # Check 7: Checking accounts for empty passwords
  echo "<h3 id=\"section_8\">7. Checking accounts for empty passwords</h3>" >> "$LOGFILE"
  generate_html_row "7. Checking accounts for empty passwords" "$(awk -F: '($2 == "") {print $1}' /etc/shadow)" >> "$LOGFILE"

  # Check 8: FTP Server Settings
  echo "<h3 id=\"section_9\">8. FTP Server Settings</h3>" >> "$LOGFILE"
  echo "<p><strong>List of FTP Users and Their Access Rights:</strong></p>" >> "$LOGFILE"
  ftp_pid=$(ps -aux | grep -E '[v]sftpd|[p]ure-ftpd' | awk '{print $2}')
  if [[ -n "$ftp_pid" ]]; then
    ftp_users=$(lsof -Pan -p "$ftp_pid" -i | grep -E 'ESTABLISHED.*ftp.*' | awk '{print $9}')
    for user in $ftp_users; do
      user_home=$(getent passwd | awk -F: -v usr="$user" '$1 == usr {print $6}')
      permissions=$(stat -c '%a' "$user_home")
      echo "<p>$user (Home: $user_home, Permissions: <strong>$permissions</strong>)</p>" >> "$LOGFILE"
    done
  else
    echo "<p>No running FTP server found.</p>" >> "$LOGFILE"
  fi

else
  echo "<p>No listening ports found on the server.</p>" >> "$LOGFILE"
fi

# Close HTML table and body
cat <<EOL >> "$LOGFILE"
    </tbody>
  </table>
</body>
</html>
EOL

# Print a message indicating the HTML file location
echo "Server scan report has been saved to $LOGFILE"

