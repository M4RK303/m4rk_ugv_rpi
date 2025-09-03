#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo."
    echo "Use 'sudo ./setup.sh' instead of './setup.sh'"
    echo "Exiting..."
    exit 1
fi

# Default value for using other source
use_index=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -i|--index)
      use_index=true
      shift
      ;;
    *)
      # Unknown option
      echo "Usage: $0 [-i | --index] (to use other source)"
      exit 1
      ;;
  esac
done

if [ -e /boot/firmware/config.txt ] ; then
  FIRMWARE=/firmware
else
  FIRMWARE=
fi
CONFIG=/boot${FIRMWARE}/config.txt

is_pi () {
  ARCH=$(dpkg --print-architecture)
  if [ "$ARCH" = "armhf" ] || [ "$ARCH" = "arm64" ] ; then
    return 0
  else
    return 1
  fi
}

if is_pi ; then
  if [ -e /proc/device-tree/chosen/os_prefix ]; then
    PREFIX="$(cat /proc/device-tree/chosen/os_prefix)"
  fi
  CMDLINE="/boot${FIRMWARE}/${PREFIX}cmdline.txt"
else
  CMDLINE=/proc/cmdline
fi

is_pifive() {
  grep -q "^Revision\s*:\s*[ 123][0-9a-fA-F][0-9a-fA-F]4[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$" /proc/cpuinfo
  return $?
}

# Config cmdline.txt
sed -i $CMDLINE -e "s/console=ttyAMA0,[0-9]\+ //"
sed -i $CMDLINE -e "s/console=serial0,[0-9]\+ //"
