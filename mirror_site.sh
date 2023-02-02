#!/bin/bash

# URL of the website to be mirrored
WEBSITE_URL="https://www.example.com"

# Directory where the website will be saved
OUTPUT_DIR="website_mirror"

# Check if wget is installed
if command -v wget > /dev/null 2>&1; then
  wget \
    --recursive \
    --no-clobber \
    --page-requisites \
    --html-extension \
    --convert-links \
    --restrict-file-names=windows \
    --domains example.com \
    --no-parent \
    --no-check-certificate \
    -P $OUTPUT_DIR \
    $WEBSITE_URL

# If wget is not installed, check if curl is installed
elif command -v curl > /dev/null 2>&1; then
  curl \
    --remote-name \
    --remote-header-name \
    --create-dirs \
    -o $OUTPUT_DIR/index.html \
    $WEBSITE_URL
else
  echo "Error: neither wget nor curl is installed."
  exit 1
fi

echo "Website mirror saved in $OUTPUT_DIR"

