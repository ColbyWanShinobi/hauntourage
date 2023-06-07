#!/bin/bash
#This script is responsible for installing and configuring the mysql server

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

root_path="/opt/yantakara"
docker_volume="mysql-data"
docker_volume_target="/var/lib/mysql"
mysql_root_password="bananaphone"

echo "Checking for docker volume: ${docker_volume}"
if docker volume ls | grep "${docker_volume}" ; then
  echo "Volume ${docker_volume} already exists"
else
  echo "Creating docker volume ${docker_volume}"
  docker volume create ${docker_volume}
fi

# Remove old Docker container if it exists
container_name="mysql"
echo "Attempting to destroy docker container: ${container_name}"
sudo docker kill "${container_name}" | true
sudo docker rm "${container_name}" | true

echo "Starting MYSQL server..."
docker run -d \
--name "${container_name}" \
-p 3306:3306 \
--mount source=${docker_volume},target=${docker_volume_target} \
-e MYSQL_ROOT_PASSWORD=${mysql_root_password} \
mysql

#Show the currently running docker containers
docker ps
