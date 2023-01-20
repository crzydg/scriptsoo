#!/bin/bash

# Prompt user for directory
echo "Enter directory path:"
read directory

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: directory does not exist"
    exit 1
fi

# Print all files in directory sorted by date
echo "List of files in $directory sorted by date:"
ls -lt "$directory"

# Prompt user for maximum age of files to be deleted
echo "Enter maximum age of files to be deleted (in days):"
read max_age

# Find and simulate deletion of all files older than max age
echo "The following files will be deleted:"
find "$directory" -type f -mtime +$max_age -print

echo "Are you sure you want to delete these files? (y/n)"
read -n 1 confirmation
if [ "$confirmation" == "y" ]; then
   find "$directory" -type f -mtime +$max_age -delete
   echo "Deleted files older than $max_age days."
else
    echo "Deletion cancelled."
fi

