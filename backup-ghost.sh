#!/bin/bash
#This script is responsible for installing and configuring a specific application.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

domain_name=$1
local_site_flag=$2
site_path=$3
root_path=$4

echo "Importing environment variables..."
. $site_path/config.env

site_provision_script="${root_path}/provision-${site_type}.sh"
backup_path=${root_path}/backup-data/${domain_name}

#https://loomchild.net/2017/03/26/backup-restore-docker-named-volumes/
#stop container
docker stop --time=60 ${domain_name} | true

#mount and tar
echo "Attempting to destroy docker container: ${container_name}"
sudo docker kill "${domain_name}-backup" | true
sudo docker rm "${domain_name}-backup" | true

backup_date=$(date -u +'%Y%m%d_%H%M')

docker run -d --rm \
--name ${domain_name}-backup \
-v ${docker_volume}:/volume \
-v ${backup_path}:/tmp \
${docker_image} \
tar -cvzf /tmp/${domain_name}-${backup_date}-backup.tar.gz -C /volume ./

#Kill the docker container so that we can make another backup with the name latest...
docker kill ${domain_name}-backup || true

docker run -d --rm \
--name ${domain_name}-backup \
-v ${docker_volume}:/volume \
-v ${backup_path}:/tmp \
${docker_image} \
tar -cvzf /tmp/${domain_name}-latest-backup.tar.gz -C /volume ./


#restart container
${site_provision_script} ${domain_name} ${local_site_flag} ${site_path}

ls -lh ${backup_path}
