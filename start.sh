#!/bin/bash
#This script is responsible for starting all the server processes.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

current_script=${0}
script_path=$(dirname ${current_script})
. ${script_path}/yantakara.env # Import environment variables from a config file

#Base server configuration has been completed. Now you can execute any application specific provisioning scripts
${script_path}/generate-local-certs.sh
${script_path}/provision-proxy.sh
${script_path}/provision-sites.sh
