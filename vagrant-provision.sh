#!/bin/bash
#This script is responsible for provisioning the host server via vagrant.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

cd /opt/hauntourage/scripts
./provision-host.sh
