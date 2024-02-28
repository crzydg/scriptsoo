#!/bin/bash

# Array of package repositories to be mirrored
REPOSITORIES=(
  "http://ftp.debian.org/debian/"
  "http://ftp.us.debian.org/debian/"
  "http://ftp.uk.debian.org/debian/"
#   customer wanted that - well than
#  "https://packages.microsoft.com/rhel/"
#  "https://packages.microsoft.com/debian/"
#  "https://packages.microsoft.com/sles/"
#  "https://packages.microsoft.com/ubuntu/"
)

# Maximum sleep time in seconds
MAX_SLEEP=60

# Check if wget is installed
if command -v wget > /dev/null 2>&1; then
  for repository in "${REPOSITORIES[@]}"; do
    repository_dir=$(echo "$repository" | sed 's/http:\/\///g' | sed 's/\//_/g')
    wget \
      --recursive \
      --no-clobber \
      --no-parent \
      --no-check-certificate \
      -nH \
      --cut-dirs=100 \
      -P $repository_dir \
      $repository

    # Sleep for a random time between 0 and MAX_SLEEP seconds
    sleep_time=$((RANDOM % MAX_SLEEP))
    sleep $sleep_time
  done
elif command -v curl > /dev/null 2>&1; then
  for repository in "${REPOSITORIES[@]}"; do
    repository_dir=$(echo "$repository" | sed 's/http:\/\///g' | sed 's/\//_/g')
    curl \
      -LJO \
      --create-dirs \
      $repository \
      -o $repository_dir/index.html

    # Sleep for a random time between 0 and MAX_SLEEP seconds
    sleep_time=$((RANDOM % MAX_SLEEP))
    sleep $sleep_time
  done
else
  echo "Error: neither wget nor curl are installed."
  exit 1
fi

echo "All package repositories have been mirrored."

