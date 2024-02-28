#!/usr/bin/perl
use strict;
use warnings;

# Prompt user for directory
print "Enter directory path: ";
my $directory = <STDIN>;
chomp $directory;

# Check if directory exists
if (!-d $directory) {
    print "Error: directory does not exist\n";
    exit 1;
}

# Print all files in directory sorted by date
my @files = sort { -M $b <=> -M $a } glob "$directory/*";
print "List of files in $directory sorted by date:\n";
foreach my $file (@files) {
    print "$file\n";
}

# Prompt user for maximum age of files to be deleted
print "Enter maximum age of files to be deleted (in days): ";
my $max_age = <STDIN>;
chomp $max_age;

# Find and simulate deletion of all files older than max age
print "The following files will be deleted:\n";
foreach my $file (@files) {
    if (-M $file > $max_age) {
        print "$file\n";
    }
}

# Confirmation
print "Are you sure you want to delete these files? (y/n)";
my $confirmation = <STDIN>;
chomp $confirmation;

# Dry run flag
print "Do you want to simulate the deletion process? (y/n)";
my $dry_run = <STDIN>;
chomp $dry_run;

if ($confirmation eq "y") {
    foreach my $file (@files) {
        if (-M $file > $max_age) {
            if ($dry_run eq "n") {
                unlink $file or warn "Could not unlink $file: $!";
                print "$file deleted\n";
            } else {
                print "$file would be deleted\n";
            }
        }
    }
    print "Deleted files older than $max_age days.\n";
} else {
    print "Deletion cancelled.\n";
}

