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


# Function to display information
information() {
  echo "ssdz - Tool to zap multiple sequential disks (clear MBR & GPT)"
  echo "Requirements:  sgdisk"
  echo "Arguments:"
  echo "-h, --help    Display this message"
  echo "-n, --number  Number of drives to process (required)"
  echo "-d, --drive   Starting drive (required)"
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
    
    echo ${drives[*]}
}

# Function to show drive list to user
show_drives() {
    echo "You have selected to zap the following drives:"
    echo ${drives[*]}
}

# Main
is_installed
handle_args "$@"
check_req_args
echo "Force is: $force"
get_starting_letter
create_drives
show_drives
