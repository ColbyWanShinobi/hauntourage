#!/bin/bash
#This script is responsible for provisioning the active sites.

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
. .${script_path}/hauntourage.env # Import environment variables from a config file

#####################################
# Functions must be declared first...
#####################################
function provision_site {
  local domain_name=${1}
  local site_path="${root_path}/sites/active/${domain_name}"

  site_config_file="${site_path}/config.env"
  if [[ -f "${site_config_file}" ]]
  then

    #Checking to see if the site is already running
    echo "Checking for docker container: ${domain_name}"
    running_container=$(docker inspect ${domain_name} --format='{{.State.Running}}' | grep 'true') || true
    
    #if docker inspect ${domain_name} --format='{{.State.Running}}' | grep "true"
    if [[ ${running_container} == "true" ]]
    then
      echo -e "Docker container ${domain_name} is already running. Skipping...\n"
      return 0
    fi
    
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
    echo -e "Found site type: ${site_type} for domain: ${domain_name}"
    provision_script=${root_path}/scripts/_provision-${site_type}.sh
    if [[ -f "${provision_script}" ]]
    then
      echo "Found provision script: ${provision_script} for site type: ${site_type}"
      ${provision_script} ${domain_name} ${local_site_flag} ${site_path} ${root_path}
    else
      echo "Missing provision script: ${provision_script} for site type: ${site_type}"
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
echo -e "Found ${#active_sites[@]} active sites \n"

#Main site provisioning loop
for i in "${active_sites[@]}";
do
  provision_site ${i}
done
