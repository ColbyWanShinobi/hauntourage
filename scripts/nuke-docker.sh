#! /bin/bash

#Stop on errors
set -e -x

#Test for admin permissions
if [ "$(id -u)" -ne "0" ]
then
  echo "You must be root to run this script."
  exit 1;
fi

echo "Killing ALL docker containers!!!"
for i in $(sudo docker ps -a | cut -c1-12 | grep -v "CONTAINER ID"); do sudo docker kill ${i} | true; done

echo "Removing ALL docker containers!!!"
for i in $(sudo docker ps -a | cut -c1-12 | grep -v "CONTAINER ID"); do sudo docker rm -f ${i} | true; done

echo "Removing all docker volumes!!!"
for i in $(sudo docker volume ls | cut -c21- | grep -v "VOLUME NAME"); do sudo docker volume rm ${i} | true; done

rm -rfv /opt/hauntourage/certs/*

#echo "Nuking ALL docker images"
#for i in $(sudo docker image ls | cut -c41-52 | grep -v "IMAGE ID"); do sudo docker image rm $i --force; done

sudo docker ps -a
sudo docker volume ls
