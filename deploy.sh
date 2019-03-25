#!/usr/bin/env bash

set -e

function debug {
  echo -e "\e[1;35m"
  echo -e "$1"
  echo -e "\e[0m"
}

VERSION=`cat mix.exs | grep version | awk '{print $2}' | tr -d '",'`
debug "deploying version ${VERSION}"

scp _build/prod/api_of_things-${VERSION}.tar.gz aot:releases/
ssh aot bash -c "cd releases && tar xzf api_of_things-${VERSION}.tar.gz && rm api_of_things-${VERSION}.tar.gz && cd .. && ./api_of_things/bin/aot stop && unlink api_of_things && ln -s releases/${VERSION} api_of_things && ./api_of_things/bin/aot start"
