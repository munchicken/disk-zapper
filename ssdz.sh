#!/bin/bash
#
#  ssdz - Sarah's Sequential Disk Zapper
#  by Sarah Pierce
#  
#  Tool to zap multiple sequential disks (clear MBR & GPT)
#  Useful for preparing a large amount of disks for zfs use.

# Function to display information
information() {
  echo "ssdz - Tool to zap multiple sequential disks (clear MBR & GPT)"
  echo "-h, --help    Display this message
  echo "-n, --number  Number of drives to process
}

# Function to handle arguments
handle_args() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        #information
        echo "help"
        exit 0
        ;;
      -n | --number)
        numOfDrives="$2"
        echo "Number of drives: $numOfDrives"
        shift
        ;;
      *)
        echo "default"
        #information
        exit 0
        ;;
    esac
    shift
done
}

# Main
handle_args "$@"
