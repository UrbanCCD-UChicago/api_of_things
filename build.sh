#!/usr/bin/env bash

set -e

function debug {
  echo -e "\e[1;35m"
  echo -e "$1"
  echo -e "\e[0m"
}

VERSION=`cat mix.exs | grep version | awk '{print $2}' | tr -d '",'`
debug "building docker image for version ${VERSION}"
docker build --no-cache --tag api_of_things:${VERSION} --build-arg VERSION=${VERSION} .

IMAGE_ID=$(docker images | grep 'api_of_things' | grep "${VERSION}" | awk '{print $3}')
debug "image id is ${IMAGE_ID}"

docker run -it -d $IMAGE_ID
CONTAINER_ID=$(docker ps | grep "$IMAGE_ID" | awk '{print $1}')
debug "container id is ${CONTAINER_ID}"

debug "copying release archive to host machine"
mkdir -p _build/prod
docker cp ${CONTAINER_ID}:/api_of_things/api_of_things-${VERSION}.tar.gz _build/prod/
docker kill ${CONTAINER_ID}

debug "uploading release archive to AWS S3"
aws s3 cp _build/prod/api_of_things-${VERSION}.tar.gz s3://api-of-things-releases/
