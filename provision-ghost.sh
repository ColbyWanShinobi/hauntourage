#!/bin/bash
#This script is responsible for installing and configuring a specific application.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

domain_name=${1}
local_site_flag=${2}
site_path=${3}
root_path=${4}

echo "Importing environment variables..."
. ${site_path}/config.env

echo "Checking for docker volume: ${docker_volume}"
if docker volume ls | grep "${docker_volume}" ; then
  echo "Volume ${docker_volume} already exists"
else
  echo "Creating docker volume ${docker_volume}"
  docker volume create ${docker_volume}
fi

# Remove old Docker container if it exists
container_name="${domain_name}"
echo "Attempting to destroy docker container: ${container_name}"
sudo docker kill "${container_name}" | true
sudo docker rm "${container_name}" | true

#Checking to see if the site is local
  site_env=$(grep site_env ${site_path}/config.env | cut -f2 -d=)
  if [[ ${site_env} == "local" ]]
  then
    echo "Starting docker container: '${container_name}' for domain: ${domain_name} with local cert..."
    docker run -d \
    --name ${container_name} \
    --mount source=${docker_volume},target=${docker_volume_target} \
    -e VIRTUAL_HOST=${virtual_host} \
    -v ${site_path}/${site_config_file}:${site_config_path}/config.production.json \
    --restart=always \
    ${docker_image}
  else
    echo "Stating docker container: '${container_name}' for domain: ${domain_name} with letsencrypt cert..."
    docker run -d \
    --name ${container_name} \
    --mount source=${docker_volume},target=${docker_volume_target} \
    -e VIRTUAL_HOST=${virtual_host} \
    -e LETSENCRYPT_HOST=${virtual_host} \
    -e LETSENCRYPT_EMAIL=${admin_email} \
    -v ${site_path}/${site_config_file}:${site_config_path}/config.production.json \
    --restart=always \
    ${docker_image}
  fi
