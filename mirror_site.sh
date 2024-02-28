#!/bin/bash

# Array of websites to be mirrored
WEBSITES=(
  "https://www.example1.com"
  "https://www.example2.com"
  "https://www.example3.com"
)

# Maximum sleep time in seconds
MAX_SLEEP=60

# Check if wget is installed
if command -v wget > /dev/null 2>&1; then
  for website in "${WEBSITES[@]}"; do
    website_dir=$(echo "$website" | sed 's/https:\/\///g' | sed 's/\//_/g')
    wget \
      --recursive \
      --no-clobber \
      --page-requisites \
      --html-extension \
      --convert-links \
      --restrict-file-names=windows \
      --no-parent \
      --no-check-certificate \
      -P $website_dir \
      $website

    # Sleep for a random time between 0 and MAX_SLEEP seconds
    sleep_time=$((RANDOM % MAX_SLEEP))
    sleep $sleep_time
  done

# If wget is not installed, check if curl is installed
elif command -v curl > /dev/null 2>&1; then
  for website in "${WEBSITES[@]}"; do
    website_dir=$(echo "$website" | sed 's/https:\/\///g' | sed 's/\//_/g')
    curl \
      --remote-name \
      --remote-header-name \
      --create-dirs \
      -o $website_dir/index.html \
      $website

    # Sleep for a random time between 0 and MAX_SLEEP seconds
    sleep_time=$((RANDOM % MAX_SLEEP))
    sleep $sleep_time
  done
else
  echo "Error: neither wget nor curl is installed."
  exit 1
fi

echo "All websites have been mirrored."

