#!/bin/bash
#
#  ssdz - Sarah's Sequential Disk Zapper
#  by Sarah Pierce
#  
#  Tool to zap multiple sequential disks (clear MBR & GPT)
#  Useful for preparing a large amount of disks for zfs use.

force=false

# Function to display information
information() {
  echo "ssdz - Tool to zap multiple sequential disks (clear MBR & GPT)"
  echo "Requirements:  sgdisk"
  echo "-h, --help    Display this message"
  echo "-n, --number  Number of drives to process"
  echo "-d, --drive   Starting drive"
  echo "-f, --force   Skip confirmation"
}

# Function to handle arguments
handle_args() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        echo "help"
        information
        exit 0
        ;;
      -n | --number)
        numOfDrives="$2"
        echo "Number of drives: $numOfDrives"
        shift
        ;;
      -d | --drive)
        startingDrive="$2"
        echo "Starting drive: $startingDrive"
        shift
        ;;
      -f | --force)
        force=true
        shift
        ;;
      *)
        echo "default"
        information
        exit 0
        ;;
    esac
    shift
done
}

# Function to verify sgdisk is installed
isInstalled() {
    if command -v sgdisk > /dev/null 2>&1; then
      echo "sgdisk is installed"
    else
      echo "sgdisk is not installed" >&2
      information
      exit 1
    fi
}

# Main
isInstalled
handle_args "$@"
echo "Force is: $force"
