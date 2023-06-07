#!/bin/bash
#This script is responsible for restoring the active sites.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

#Check to ensure that these required external commands are present before we begin
#Commands to look for: aws
#CMDARR=(aws)
#for ITEM in ${CMDARR[*]}
#do
#  if ! [ -x "$(command -v ${ITEM})" ]
#    then
#      echo "Error: ${ITEM} is not installed"
#      exit 1
#  fi
#done

current_script=${0}
script_path=$(dirname ${current_script})
. ${script_path}/yantakara.env # Import environment variables from a config file
#. ${script_path}/object-storage.env # Import object storage environment variables from a config file

domain_name=${1}
site_path="${root_path}/sites/active/${domain_name}"

#Check for environment variable
if [ -z "${domain_name}" ]
then
  echo You must supply a valid domain name as the first parameter
  echo usage: "${0}" example.com
  exit 1
fi

site_config_file="${site_path}/config.env"
if [[ -f "${site_config_file}" ]]
then
  echo "Found site config file for domain: ${domain_name}"
  
  #Checking to see if the site is local
  site_env=$(grep site_env ${site_path}/config.env | cut -f2 -d=)
  if [[ ${site_env} == "local" ]]
  then
    echo "Found LOCAL site: ${domain_name}"
    local_site_flag=true
  else
    echo "Found PUBLIC site: ${domain_name}"
    local_site_flag=false
  fi

  #Determine site type
  site_type=$(grep site_type ${site_path}/config.env | cut -f2 -d=)
  echo "Found site type: ${site_type} for domain: ${domain_name}"
  restore_script=${root_path}/restore-${site_type}.sh
  if [[ -f "${restore_script}" ]]
  then
    echo "Found restore script: ${restore_script} for site type: ${site_type}"
    ${restore_script} ${domain_name} ${local_site_flag} ${site_path} ${root_path}
  else
    echo "Missing restore script: ${restore_script} for site type: ${site_type}"
  fi

else
  echo "No site config file for domain: ${domain_name}"
fi






#####################################
# Functions must be declared first...
#####################################
#function restore_site {
  

  
#}
###############
# End Functions 
###############

#declare -a active_sites
#active_site_count=0
#readarray -t active_sites < <(find $root_path/sites/active -maxdepth 1 -type d -printf '%P\n' | grep .)
#echo "There are ${#active_sites[@]} active sites to backup"

#Backup cert files
#backup_path=${root_path}/backup-data
#backup_date=$(date -u +'%Y%m%d_%H%M')
#tar -cvzf ${backup_path}/default-cert-${backup_date}-backup.tar.gz ${root_path}/certs/dhparam.pem ${root_path}/certs/default.crt ${root_path}/certs/default.key
#tar -cvzf ${backup_path}/default-cert-latest-backup.tar.gz ${root_path}/certs/dhparam.pem ${root_path}/certs/default.crt ${root_path}/certs/default.key


#tar -cvzf ${backup_path}/

#Main site backup loop
#for i in "${active_sites[@]}";
#do
  #Backup Certificates
  #tar -cvzf ${backup_path}/${i}-cert-${backup_date}-backup.tar.gz ${root_path}/certs/${i}.crt ${root_path}/certs/${i}.key
  #tar -cvzf ${backup_path}/${i}-cert-latest-backup.tar.gz ${root_path}/certs/${i}.crt ${root_path}/certs/${i}.key

  #Backup Site
  #backup_site $i
#done
