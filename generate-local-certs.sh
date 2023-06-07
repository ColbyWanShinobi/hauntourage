#!/bin/bash
#This script is responsible for generating a local certificate.

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must have root permissions to run this script."
  exit 1;
fi

current_script=$0
script_path=$(dirname ${current_script})
. ${script_path}/yantakara.env # Import environment variables from a config file

function check_site {
  local domain_name=${1}
  local domain_number=${2}
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

    if [[ ${local_site_flag}=true ]]
    then
      key_filename=${domain_name}.key
      cert_config_file=${root_path}/certs/${domain_name}.conf
      
      if [[ ! -f ${root_path}/certs/${domain_name}.crt ]]
      then
        #I used to remove the key but I'm testing the non-destructive approach now
        #rm ${root_path}/certs/${domain_name}.* | true'
        
        openssl req \
        -x509 \
        -nodes \
        -subj "/CN=${domain_name}" \
        -days 365 \
        -newkey rsa:2048 \
        -keyout "${root_path}/certs/${domain_name}.key" \
        -out "${root_path}/certs/${domain_name}.crt"

        echo -e "Key successfully created for local domain: ${domain_name}\n"
      else
        echo -e "Key already present for local domain: ${domain_name}\n"
      fi
    fi

  else
    echo "No site config file for domain: ${domain_name}"
  fi
}

declare -a active_sites
active_site_count=1
readarray -t active_sites < <(find ${root_path}/sites/active -maxdepth 1 -type d -printf '%P\n' | grep .)
echo -e "There are ${#active_sites[@]} active sites that need certs. Checking for local sites...\n"

#Main site provisioning loop
for i in "${active_sites[@]}";
do
  check_site ${i} ${active_site_count}
  active_site_count=$((active_site_count + 1))
done
