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

# Main
information
