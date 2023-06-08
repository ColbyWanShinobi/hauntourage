#!/bin/bash
#This script is responsible for restarting all the active sites and services. EVERYTHING is restarted.

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
#
function stop_site {
  local domain_name=${1}
  local site_path="${root_path}/sites/active/${domain_name}"

  site_config_file="${site_path}/config.env"
  if [[ -f "${site_config_file}" ]]
  then 

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

    echo "Stopping container for domain: ${domain_name}"
    docker stop --time=60 ${domain_name} | true

  else
    echo "No site config file for domain: ${domain_name}"
  fi
}

function start_site {
  local domain_name=${1}
  local site_path="${root_path}/sites/active/${domain_name}"

  #Determine site type
  local site_type=$(grep site_type ${site_path}/config.env | cut -f2 -d=)
  echo "Found site type: ${site_type} for domain: ${domain_name}"

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

  site_config_file="${site_path}/config.env"
  if [[ -f "${site_config_file}" ]]
  then    
    echo "Starting container for domain: ${domain_name}"
    site_provision_script="${root_path}/scripts/_provision-${site_type}.sh"
    proxy_provision_script="${root_path}/scripts/_provision-proxy.sh"
    echo ${site_provision_script} ${domain_name} ${local_site_flag} ${site_path}
    ${site_provision_script} ${domain_name} ${local_site_flag} ${site_path}
    sudo docker restart "${domain_name}" | true
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
echo "There are ${#active_sites[@]} active sites to restart"

#Main site backup loop
for i in "${active_sites[@]}";
do
  #Stop Site
  echo "Stopping site for domain: ${domain} ..."
  stop_site ${i}
  
  #restart db
  
  echo "Restarting proxy..."
  ${proxy_provision_script}

  echo "Starting site for domain: ${domain} ..."
  start_site ${i}
  
done

docker ps
