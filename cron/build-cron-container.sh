#!/bin/bash
#This script is responsible for creating the cron docker container

set -e # -e  Exit immediately if a command exits with a non-zero status.
set -x # -x  Print commands and their arguments as they are executed.

SCRIPTDIR=$(dirname "$0")

APP_NAME="cron-mysql"

# Prep folder
#rm -rf ../$ACCUSOFT_ROLE-*.*
IMAGE="cron-mysql"
VERSION=1

# Cleanup Docker
#docker ps -a -q | xargs docker kill | true
#docker ps -a -q | xargs docker rm -f | true
#docker images -q | xargs docker rmi -f | true

# Cleanup Docker
docker kill "$IMAGE" | true
docker rm "$IMAGE" | true
docker rmi "$IMAGE" | true

# Create image from dockerfile
docker build --build-arg --force-rm=true -t $IMAGE:$VERSION .
#Commands in Dockerfile run here!
###docker tag -f $IMAGE:$ACCUSOFT_VERSION $IMAGE:latest
docker tag $IMAGE:$VERSION $IMAGE:latest

echo "Successfully created new $APP_NAME image"

docker run -d \
--name "${IMAGE}" \
$IMAGE:$VERSION
