#!/bin/bash
#This script is responsible for installing and configuring the nginx proxy

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

echo "Killing Reverse Proxy..."

# Remove old Docker container if it exists
container_name="nginx-proxy"
echo "Attempting to destroy docker containers: ${container_name} and ${container_name}-letsencrypt"
sudo docker kill "${container_name}" | true
sudo docker rm "${container_name}" | true
sudo docker kill "${container_name}-letsencrypt" | true
sudo docker rm "${container_name}-letsencrypt" | true

#Show the currently running docker containers
docker ps
