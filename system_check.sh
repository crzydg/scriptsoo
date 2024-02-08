#!/bin/bash

# Output file
output="system_report.html"

# Start HTML Document
echo "<html><head><title>System Report</title></head><body>" > $output
echo "<h1>System Report</h1>" >> $output
echo "<h2>Table of Contents</h2>" >> $output
echo "<ul>" >> $output

# Function to add TOC entry
add_toc_entry() {
    echo "<li><a href='#$1'>$2</a></li>" >> $output
}

# Add TOC entries
add_toc_entry "kernel_info" "Linux Kernel Information"
add_toc_entry "user_id" "Current User and ID Information"
add_toc_entry "distro_info" "Linux Distribution Information"
add_toc_entry "logged_users" "List Current Logged In Users"
add_toc_entry "uptime_info" "Uptime Information"
add_toc_entry "running_services" "Running Services"
add_toc_entry "net_connections" "Active Internet Connections and Open Ports"
add_toc_entry "disk_space" "Check Available Space"
add_toc_entry "memory_check" "Check Memory"
add_toc_entry "history_cmds" "History (Commands)"
add_toc_entry "net_interfaces" "Network Interfaces"
add_toc_entry "iptables_info" "IPtable Information"
add_toc_entry "running_procs" "Check Running Processes"
add_toc_entry "ssh_config" "Check SSH Configuration"
add_toc_entry "installed_packages" "List all Packages Installed"
add_toc_entry "network_params" "Network Parameters"
add_toc_entry "password_policies" "Password Policies"
add_toc_entry "source_list" "Check your Source List File"
add_toc_entry "broken_deps" "Check for Broken Dependencies"
add_toc_entry "motd_banner" "MOTD Banner Message"
add_toc_entry "user_names" "List User Names"
add_toc_entry "null_passwords" "Check for Null Passwords"
add_toc_entry "ip_routing" "IP Routing Table"
add_toc_entry "kernel_msgs" "Kernel Messages"
add_toc_entry "upgradable_pkgs" "Check Upgradable Packages"
add_toc_entry "cpu_info" "CPU/System Information"
add_toc_entry "tcp_wrappers" "TCP Wrappers"
add_toc_entry "failed_logins" "Failed Login Attempts"

# Close TOC
echo "</ul>" >> $output

# Function to add section
add_section() {
    echo "<h3 id='$1'>$2</h3>" >> $output
    echo "<pre>" >> $output
    eval $3 >> $output
    echo "</pre>" >> $output
}

# Add sections with content
add_section "kernel_info" "Linux Kernel Information" "uname -a"
# ... [Repeat for each section]
# Add the remaining sections here following the same format as above

# End HTML Document
echo "</body></html>" >> $output

