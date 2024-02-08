#!/bin/bash

# Directory containing Apache virtual host configs
config_dir="/etc/apache2/sites-enabled"

# Iterate over each .conf file
for conf in "$config_dir"/*.conf; do
    # Extract the name of the config file without path and extension
    conf_name=$(basename "$conf" .conf)

    # Output file named after the virtual host
    output="${conf_name}_report.html"

    # Start HTML Document for each virtual host
    echo "<html><head><title>Apache Virtual Host: $conf_name Report</title></head><body>" > "$output"
    echo "<h1>Apache Virtual Host: $conf_name Report</h1>" >> "$output"
    echo "<h2>Configuration Details</h2>" >> "$output"
    echo "<pre>" >> "$output"

    # Add the contents of the virtual host configuration file
    cat "$conf" >> "$output"

    echo "</pre>" >> "$output"
    # End HTML Document
    echo "</body></html>" >> "$output"
done

