#!/bin/bash
#
#  ssdz - Sarah's Sequential Disk Zapper
#  by Sarah Pierce
#  
#  Tool to zap multiple sequential disks (clear MBR & GPT)
#  Useful for preparing a large amount of disks for zfs use.

# Variables
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
  echo "  -h, --help    Display this message"
  echo "  -n, --number  Number of drives to process (required)"
  echo "  -d, --drive   Starting drive (required)"
  echo "  -f, --force   Skip confirmation"
  echo "Limitations:"
  echo "  Must start on one of first 26 disks /dev/sda - /dev/sdz"
  echo "  Usable up to /dev/sdaz"
  echo "Examples:"
  echo "  ssdz -h"
  echo "  ssdz -n 12 -d /dev/sdc"
  echo "  ssdz -n 5 -d /dev/sde -f"
}

# Function to handle arguments
handle_args() {
  if [[ $# -eq 0 ]]; then
    information
    exit 0
  fi    

  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        #echo "help"  #DEBUG
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
              echo "Error:  Number of drives must be greater than zero." >&2
              echo
              information
              exit 1
            else
              numOfDrives="$2"
              #echo "Number of drives: $numOfDrives"  #DEBUG
              shift
            fi
          else
            echo "Error:  $2 is not a number. Number of drives must be a number." >&2
            echo
            information
            exit 1
          fi
        else
          echo "Error:  Number of drives must be specified" >&2
          echo
          information
          exit 1
        fi
        ;;
      -d | --drive)
        # test if in format /dev/sdx
        #   currently only supporting /dev/sdx, will try to accommodate /dev/sdxx in next ver
        if [[ $2 =~ /dev/sd[a-z]{1}$ ]]; then
          startingDrive="$2"
          #echo "Starting drive: $startingDrive"  #DEBUG
          shift
        else
          echo "Error:  Starting drive must be in format /dev/sdx" >&2
          echo
          information
          exit 1
        fi
        ;;
      -f | --force)
        force=true
        shift
        ;;
      *)
        #echo "default"  #DEBUG
        echo "Error:  Invalid argument" >&2
        echo
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
      #echo "sgdisk is installed"  #DEBUG
      :  #no-op after debugging
    else
      echo "Error:  sgdisk is not installed" >&2
      echo
      information
      exit 1
    fi
}

# Function to verify required arguments exist
check_req_args() {
    if ! [[ -n "$numOfDrives" ]]; then
      echo "Error:  Number of drives is required." >&2
      echo
      information
      exit 1
    fi

    if ! [[ -n "$startingDrive" ]]; then
      echo "Error:  Starting drive is required." >&2
      echo
      information
      exit 1
    fi
}

# Function to get the starting letter
get_starting_letter() {
    # remove template from startingDrive to get letter
    startingLetter="${startingDrive#$template}"
    #echo "Starting letter is: $startingLetter"  #DEBUG
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
    #echo "Index of starting letter is: $(index_of_starting_letter)"  #DEBUG
    i=$(index_of_starting_letter)
    currentDrive=$startingDrive
    #echo "Current drive is: $currentDrive"  #DEBUG

    while [ $numOfDrives -gt 0 ]; do
      drives+=($currentDrive)

      # check if we are at z
      if [[ i -eq 25 ]]; then
        # change template to add an 'a' '/dev/sda', so next would be /sdaa, /sdab, etc
        template+=${alphabet[0]}
        # loop back around to a
        i=0
      else
        ((i++))
      fi

      # check if we went past /sdaz
      #   currently program adds another 'a' instead of restarting with b (/sdaaa not /sdba)
      #   will try to accommodate another set of 26 drives in next version
      if [ $currentDrive = /dev/sdaaa ]; then
        #echo "Exceeded limitation at: $currentDrive"  #DEBUG
        echo "Error:  Exceeded limitation, exiting.  (past /dev/sdaz)" >&2
        echo
        information
        exit 1
      fi

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
    #echo "Force is: $force"  #DEBUG
    if [ "$force" = false ]; then
      show_drives
      read -p "Do you want to continue? y/n " confirmation
      #echo "You responded: $confirmation"  #DEBUG
      if [[ $confirmation != y ]]; then
        echo "User abort.  Exiting..."
        exit 0
      fi
    fi
    zap_drives
}

# Function to zap drives with sgdisk
zap_drives() {
    echo "Zapping drives!"

    for drive in "${drives[@]}"; do
      echo "sgdisk -Z $drive"  #DEBUG
      sgdisk -Z $drive
      returnCode=$?
      #returnCode=1  #DEBUG
      #echo "Exit code: $returnCode"  #DEBUG
      if [ $returnCode -gt 0 ]; then
        echo
        echo "ssdz: sgdisk failed" >&2
        exit 1
      fi
    done
    echo "All drives zapped!"
}

# Main
handle_args "$@"
is_installed
check_req_args
create_drives
show_title
handle_confirmation
