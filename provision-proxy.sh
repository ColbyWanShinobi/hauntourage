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

# Remove old Docker container if it exists
container_name="nginx-proxy"
echo "Attempting to destroy docker containers: ${container_name} and ${container_name}-letsencrypt"
sudo docker kill "${container_name}" | true
sudo docker rm "${container_name}" | true
sudo docker kill "${container_name}-letsencrypt" | true
sudo docker rm "${container_name}-letsencrypt" | true

echo "Starting Reverse Proxy..."
####
docker run -d \
--name "${container_name}" \
-p 80:80 \
-p 443:443 \
-v /var/run/docker.sock:/tmp/docker.sock:ro \
-v ${root_path}/certs:/etc/nginx/certs \
-v ${root_path}/nginx/vhost.d:/etc/nginx/vhost.d \
-v /etc/nginx/certs \
-v /etc/nginx/vhost.d \
-v /usr/share/nginx/html \
jwilder/nginx-proxy

docker run --detach \
--name "${container_name}-letsencrypt" \
--volumes-from ${container_name} \
--volume /var/run/docker.sock:/var/run/docker.sock:ro \
jrcs/letsencrypt-nginx-proxy-companion

#Show the currently running docker containers
docker ps
