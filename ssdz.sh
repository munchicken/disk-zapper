#!/bin/bash
#
#  ssdz - Sarah's Sequential Disk Zapper
#  by Sarah Pierce
#  
#  Tool to zap multiple sequential disks (clear MBR & GPT)
#  Useful for preparing a large amount of disks for zfs use.

force=false
template="/dev/sd"
declare -a alphabet=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
declare -a drives=()

# Function to display title
show_title() {
    echo "ssdz - Tool to zap multiple sequential disks (clear MBR & GPT)"
}

# Function to display information
information() {
  show_title
  echo "Requirements:  sgdisk"
  echo "Arguments:"
  echo "-h, --help    Display this message"
  echo "-n, --number  Number of drives to process (required)"
  echo "-d, --drive   Starting drive (required)"
  echo "-f, --force   Skip confirmation"
  echo "Examples:"
  echo "ssdz -h"
  echo "ssdz -n 12 -d /dev/sdc"
  echo "ssdz -n 5 -d /dev/sde -f"
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
        # test for argument
        if [[ -n "$2" ]]; then
          # test if argument is a number
          if [[ $2 =~ ^-?[0-9]+$ ]]; then
            # test if argument is nonzero & positive
            if [ $2 -lt 1 ]; then
              echo "Number of drives must be greater than zero." >&2
              exit 1
            else
              numOfDrives="$2"
              echo "Number of drives: $numOfDrives"
              shift
            fi
          else
            echo "$2 is not a number. Number of drives must be a number." >&2
            exit 1
          fi
        else
          echo "Error:  Number of drives must be specified" >&2
          exit 1
        fi
        ;;
      -d | --drive)
        # test if in format /dev/sdx
        if [[ $2 =~ /dev/sd[a-z]{1}$ ]]; then
          startingDrive="$2"
          echo "Starting drive: $startingDrive"
          shift
        else
          echo "Starting drive must be in format /dev/sdx" >&2
          exit 1
        fi
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
is_installed() {
    if command -v sgdisk > /dev/null 2>&1; then
      echo "sgdisk is installed"
    else
      echo "sgdisk is not installed" >&2
      information
      exit 1
    fi
}

# Function to verify required arguments exist
check_req_args() {
    if ! [[ -n "$numOfDrives" ]]; then
      echo "Number of drives is required." >&2
      information
      exit 1
    fi

    if ! [[ -n "$startingDrive" ]]; then
      echo "Starting drive is required." >&2
      information
      exit 1
    fi
}

# Function to get the starting letter
get_starting_letter() {
    # remove template from startingDrive to get letter
    startingLetter="${startingDrive#$template}"
    echo "Starting letter is: $startingLetter"
}

# Function to find index of starting letter
index_of_starting_letter() {
    for ((j=0; j<${#alphabet[@]}; j++)); do
      if [[ ${alphabet[$j]} == $startingLetter ]]; then
        echo "$j"  #return j
      fi
    done
}

# Fuction to create array of drives
create_drives() {
    get_starting_letter
    echo "Index of starting letter is: $(index_of_starting_letter)"
    i=$(index_of_starting_letter)
    currentDrive=$startingDrive
    echo "Current drive is: $currentDrive"

    while [ $numOfDrives -gt 0 ]; do
      drives+=($currentDrive)
      ((i++))
      currentDrive=$template${alphabet[$i]}
      ((numOfDrives--))
    done
}

# Function to show drive list to user
show_drives() {
    echo "You have selected to zap the following drives:"
    echo ${drives[*]}
}

# Function to handle confirmation to zap drives
handle_confirmation() {
    echo "Force is: $force"
    if [ "$force" = false ]; then
      show_drives
      read -p "Do you want to continue? y/n " confirmation
      echo "You responded: $confirmation"
      if [[ $confirmation != y ]]; then
        echo "Exiting..."
        exit 0
      fi
    fi
    zap_drives
}

# Function to zap drives with sgdisk
zap_drives() {
    echo "Zapping drives!"

    for drive in "${drives[@]}"; do
      echo "sgdisk -Z $drive"
    done
    echo "All drives zapped"
}

# Main
handle_args "$@"
is_installed
show_title
check_req_args
create_drives
handle_confirmation
