#!/bin/bash
#This script is responsible for backing up the active sites.

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

#####################################
# Functions must be declared first...
#####################################
function backup_site {
  local domain_name=${1}
  local site_path="${root_path}/sites/active/${domain_name}"

  site_config_file="${site_path}/config.env"
  if [[ -f "${site_config_file}" ]]
  then
    echo "Found site config file for domain: ${domain_name}"
    
    #Checking to see if the site is local
    local site_env=$(grep site_env ${site_path}/config.env | cut -f2 -d=)
    if [[ ${site_env} == "local" ]]
    then
      echo "Found LOCAL site: ${domain_name}"
      local local_site_flag=true
    else
      echo "Found PUBLIC site: ${domain_name}"
      local local_site_flag=false
    fi

    #Determine site type
    local site_type=$(grep site_type ${site_path}/config.env | cut -f2 -d=)
    echo "Found site type: ${site_type} for domain: ${domain_name}"
    backup_script=${root_path}/backup-${site_type}.sh
    if [[ -f "${backup_script}" ]]
    then
      echo "Found backup script: ${backup_script} for site type: ${site_type}"
      ${backup_script} ${domain_name} ${local_site_flag} ${site_path} ${root_path}
    else
      echo "Missing backup script: ${backup_script} for site type: ${site_type}"
    fi

  else
    echo "No site config file for domain: ${domain_name}"
  fi
}
###############
# End Functions 
###############

declare -a active_sites
active_site_count=0
readarray -t active_sites < <(find ${root_path}/sites/active -maxdepth 1 -type d -printf '%P\n' | grep .)
echo "There are ${#active_sites[@]} active sites to backup"

#Backup cert files
backup_path=${root_path}/backup-data
backup_date=$(date -u +'%Y%m%d_%H%M')
#echo $root_path
#echo $backup_path
mkdir -p ${backup_path}/default
tar -cvzf ${backup_path}/default/default-cert-${backup_date}-backup.tar.gz -C ${root_path}/certs ./dhparam.pem ./default.crt ./default.key 
tar -cvzf ${backup_path}/default/default-cert-latest-backup.tar.gz -C ${root_path}/certs ./dhparam.pem ./default.crt ./default.key 


#tar -cvzf ${backup_path}/

#Main site backup loop
for i in "${active_sites[@]}";
do
  #Backup Certificates
  mkdir -p ${backup_path}/${i}
  tar -cvzf ${backup_path}/${i}/${i}-cert-${backup_date}-backup.tar.gz -C ${root_path}/certs ./${i}.crt ./${i}.key
  tar -cvzf ${backup_path}/${i}/${i}-cert-latest-backup.tar.gz -C ${root_path}/certs ./${i}.crt ./${i}.key 

  #Backup Site
  backup_site ${i}
done
