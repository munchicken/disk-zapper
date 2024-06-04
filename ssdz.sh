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
      *)
        echo "default"
        exit 0
        ;;
    esac
    shift
done
}

# Main
handle_args "$@"
