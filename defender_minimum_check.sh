#!/bin/bash

# Define the servers to be checked
servers=("server1" "server2" "server3")

# Define the minimum requirements for Defender for Linux
defender_architecture="x86_64"
defender_distribution="(Ubuntu|Debian|Red Hat|SUSE)"
defender_kernel="3.10"
defender_ram="1"
defender_space="2"

# Define the minimum requirements for Tetration
tetration_cpu_threads=8
tetration_memory=32
tetration_storage=100

# Loop through each server
for server in ${servers[@]}; do
    echo "Checking server: $server"
    echo "Checking Defender for Linux compatibility:"
    # Check the architecture of the system
    architecture=$(ssh $server "uname -m")
    if [[ $architecture =~ $defender_architecture ]]; then
        echo "Architecture: $architecture (compatible)"
    else
        echo "Architecture: $architecture (not compatible)"
    fi

    # Check the distribution and version
    distribution=$(ssh $server "cat /etc/os-release" | grep -Eo $defender_distribution)
    if [[ -n $distribution ]]; then
        echo "Distribution: $distribution (compatible)"
    else
        echo "Distribution: Unknown (not compatible)"
    fi

    # Check the kernel version
    kernel=$(ssh $server "uname -r" | grep -Eo "[0-9]+.[0-9]+.[0-9]+")
    if [[ $kernel =~ $defender_kernel ]]; then
        echo "Kernel: $kernel (compatible)"
    else
        echo "Kernel: $kernel (not compatible)"
    fi

    # Check the amount of RAM
    ram=$(ssh $server "free -m" | grep Mem | awk '{print $2}')
    if [[ $ram -ge $defender_ram ]]; then
        echo "RAM: $ram MB (compatible)"
    else
        echo "RAM: $ram MB (not compatible)"
    fi

    # Check the amount of free space
    space=$(ssh $server "df -h /" | tail -1 | awk '{print $4}' | tr -d G)
    if [[ $space -ge $defender_space ]]; then
        echo "Free space: $space GB (compatible)"
    else
        echo "Free space: $space GB (not compatible)"
    fi
    
    echo "Checking Tetration compatibility:"
    cpu_threads=$(ssh $server "nproc")
    if [[ $cpu_threads -ge $tetration_cpu_threads ]]; then
        echo "CPU threads: $cpu_threads (compatible)"
    else
        echo "CPU threads: $cpu_threads (not compatible)"
    fi

    memory=$(ssh $server "free -m" | grep Mem | awk '{print $2}')
    if [[ $memory -ge $tetration_memory ]]; then
        echo "Memory: $memory MB (compatible)"
    else
        echo "Memory: $memory MB (not compatible)"
    fi

    storage=$(ssh $server "df -h /" | tail -1 | awk '{print $4}' | tr -d G)
    if [[ $storage -ge $tetration_storage ]]; then
        echo "Storage: $storage GB (compatible)"
    else
        echo "Storage: $storage GB (not compatible)"
    fi
    
done

