#!/bin/bash

# Parse command line arguments
while getopts ":r:n:t:" opt; do
  case $opt in
    r)
      relayhost=$OPTARG
      ;;
    n)
      mynetworks=$OPTARG
      ;;
    t)
      test_email=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if required arguments are set
if [ -z "${relayhost}" ]; then
  echo "Relay host (-r) is required." >&2
  exit 1
fi

# Install Postfix and mailutils
sudo apt update
sudo apt install -y postfix mailutils

# Backup the original Postfix configuration file
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bak

# Edit the Postfix configuration file with sed
sudo sed -i -e "s/^relayhost =.*/relayhost = ${relayhost}/" \
-e "/^#mynetworks =/a mynetworks = ${mynetworks}" /etc/postfix/main.cf

# Restart Postfix
sudo service postfix restart

# Test the mail relay
if [ -z "${test_email}" ]; then
  echo "Test email (-t) is not set. Skipping test."
else
  echo "This is a test email" | mail -s "Test Email" ${test_email}
fi

