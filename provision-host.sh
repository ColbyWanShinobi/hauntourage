#!/bin/bash
#This script is responsible for provisioning the host server.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

current_script=${0}
echo ${current_script}
script_path=$(dirname ${current_script})
echo "Current Path: ${script_path}"
pwd
ls -alh
. ${script_path}/yantakara.env # Import environment variables from a config file

echo "This script will provision the host server. It will get the server ready for application installation."

echo "Updating the repositories..."
apt-get update -y

echo "Upgrading the base packages..."
apt-get upgrade -y

#If you're using a cloud provider or vagrant, ssh will already be installed most likely.
#If you are trying to use this script on any other install, make sure that the ssh server is installed
#apt-get install openssh-server -y

echo "Installing system utilities..."
apt-get install htop docker.io awscli -y

#Setup Firewall
echo "Checking for installed firewall..."
if ! [ -x "$(command -v ufw)" ]; then
  echo 'ufw is not installed. Installing...' >&2
  apt-get install ufw -y
fi

echo "Set default firewall rule: DENY all incoming traffic..."
ufw default deny incoming

echo "Set default firewall rule: ALLOW all outgoing traffic..."
ufw default allow outgoing

echo "Set default firewall rule: ALLOW SSH..."
ufw allow ssh
ufw allow http
ufw allow https

echo "Starting the firewall..."
ufw disable
yes | ufw enable

#Provisioning complete. Now start the server processes.
${script_path}/start.sh
