#!/bin/bash
#This script is responsible for uploading the backup files to your object storage (aws-s3, etc).

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
CMDARR=(aws)
for ITEM in ${CMDARR[*]}
do
  if ! [ -x "$(command -v ${ITEM})" ]
    then
      echo "Error: ${ITEM} is not installed"
      exit 1
  fi
done

current_script=${0}
script_path=$(dirname ${current_script})
. ${script_path}/yantakara.env # Import environment variables from a config file
. ${script_path}/object-storage.env # Import environment variables from a config file

echo $object_storage_id
