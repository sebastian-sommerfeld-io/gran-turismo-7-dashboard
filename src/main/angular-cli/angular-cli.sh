#!/bin/bash
# @file angular-cli.sh
# @brief Build and use the angular-cli helper (docker image).
#
# @description This script handles all commands of the angular-cli helper (docker image).
#
# ==== Arguments
#
# The script does not accept any parameters.


CMD_BUILD="build_image"
CMD_INIT="init_webapp"

ANTORA_CLI="local/ansible-cli:dev"

WEBAPP_DIR="webapp"


# @description Initialize Angular webapp in src/main/webapp
function initWebapp() {
  echo -e "$LOG_INFO Initialize Angular webapp"

  (
    cd .. || exit

    if [ -d "$WEBAPP_DIR" ]; then
      echo -e "$LOG_ERROR Cannot initialize Angular Webapp. Directory '$P$WEBAPP_DIR$D' already exists."
      echo -e "$LOG_ERROR Exit" && exit
    fi

    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      "$ANTORA_CLI" ng new "$WEBAPP_DIR"
  )
}


echo -e "$LOG_INFO What should I do?"
select o in "$CMD_BUILD" "$CMD_INIT"; do
  case "$o" in
    "$CMD_BUILD" )
      echo -e "$LOG_INFO Lint dockerfile"
      docker run --rm -i hadolint/hadolint:latest < Dockerfile

      echo -e "$LOG_INFO Build this helper image"
      docker build -t "$ANTORA_CLI" .

      break;;
    "$CMD_INIT" )
      initWebapp
      
      break;;
  esac
done
