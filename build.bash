#!/bin/bash

set -e

# uncomment the next line if you have issues and need verbose output
# set -x


# read in cmd args

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -t|--tag)
        TAG="$2"
        shift # past argument
        shift # past value
      ;;
      --skip-upload)
        SKIP_UPLOAD=true
        shift # past argument
      ;;
      *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


# colorized output

CYAN="\e[1;36m"
RED="\e[1;31m"
GREEN="\e[1;32m"
NORM="\e[0m"

function printcyan {
  echo -e "${CYAN}$1${NORM}"
}

function printred {
  echo -e "${RED}$1${NORM}"
}

function printgreen {
  echo -e "${GREEN}$1${NORM}"
}


# get tag

if [ -z "$TAG" ];
then
  printred "you need to specify a tag!";
  exit 1;
fi

printcyan "building docker image for tag $TAG ..."
docker build --no-cache --tag api_of_things:$TAG --build-arg tag=$TAG .


# get docker image id

IMAGE_ID=$(docker images | grep "$TAG" | awk '{print $3}')
printcyan "docker image id is $IMAGE_ID"


# run the docker container as a daemon

printcyan "running docker image so we can generate the release archive..."
docker run -it -d $IMAGE_ID

CONTAINER_ID=$(docker ps | grep "$IMAGE_ID" | awk '{print $1}')
printcyan "docker container id is $CONTAINER_ID"


# build the release archive

printcyan "copying prod secret to the container..."
docker cp ./config/prod.secret.exs $CONTAINER_ID:/api_of_things/config/prod.secret.exs

printcyan "building the release..."
docker exec -it $CONTAINER_ID sh -c 'MIX_ENV=prod mix release --env=prod'

printcyan "making a tarball for the release..."
if [ -d "_build/prod" ];
then
  mkdir -p _build/prod;
fi
docker exec -it $CONTAINER_ID tar czf api_of_things-$TAG.tar.gz /api_of_things/_build/prod/rel/api_of_things

printcyan "copying the release archive to your host machine..."
docker cp $CONTAINER_ID:/api_of_things/api_of_things-$TAG.tar.gz _build/prod/


# stop the docker container

printcyan "stopping the docker container..."
docker stop $CONTAINER_ID


# extract and retag archive

printcyan "extracting archive and retagging it..."
cd _build/prod
tar xzf api_of_things-$TAG.tar.gz
mv ./api_of_things/_build/prod/rel/api_of_things ./$TAG
rm -r ./api_of_things
rm api_of_things-$TAG.tar.gz
tar czf api_of_things-$TAG.tar.gz $TAG
rm -r $TAG
cd ../..


# upload the archive

if [ "$SKIP_UPLOAD" = true ];
then
  printcyan "skipping upload to S3..."
else
  printcyan "uploading release archive to S3..."
  aws s3 cp _build/prod/api_of_things-$TAG.tar.gz s3://api_of_things-releases/
fi


# done

printgreen "DONE!"
