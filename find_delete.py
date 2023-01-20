import os
import glob
from datetime import datetime

# Prompt user for directory
directory = input("Enter directory path: ")

# Check if directory exists
if not os.path.isdir(directory):
    print("Error: directory does not exist")
    exit(1)

# Print all files in directory sorted by date
files = glob.glob(f"{directory}/*")
files.sort(key=lambda x: os.path.getmtime(x))
print("List of files in {} sorted by date:".format(directory))
for file in files:
    print(file)

# Prompt user for maximum age of files to be deleted
max_age = int(input("Enter maximum age of files to be deleted (in days): "))

# Find and simulate deletion of all files older than max age
print("The following files will be deleted:")
for file in files:
    file_age = (datetime.now() - datetime.fromtimestamp(os.path.getmtime(file))).days
    if file_age > max_age:
        print(file)

# Confirmation
confirmation = input("Are you sure you want to delete these files? (y/n)")

# Dry run flag
dry_run = input("Do you want to simulate the deletion process? (y/n)")

if confirmation == "y":
    for file in files:
        file_age = (datetime.now() - datetime.fromtimestamp(os.path.getmtime(file))).days
        if file_age > max_age:
            if dry_run == 'n':
                os.remove(file)
                print(file + " deleted")
            else:
                print(file + " would be deleted")
    print("Deleted files older than {} days.".format(max_age))
else:
    print("Deletion cancelled.")

