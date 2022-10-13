#!/bin/bash
# @file angular-cli.sh
# @brief Build and use the angular-cli helper (docker image).
#
# @description This script handles all commands of the angular-cli helper (docker image).
#
# ==== Arguments
#
# The script does not accept any parameters.


CMD_CLI_BUILD="build_image"
CMD_NG_INIT="init"
CMD_NG_SERVE="serve_dev"
CMD_NG_BUILD="build"
CMD_NG_TEST="unit_test"

ANTORA_CLI="local/ansible-cli:dev"

WEBAPP_DIR="webapp"


# @description Initialize Angular webapp in src/main/webapp
function initWebapp() {
  echo -e "$LOG_INFO Initialize Angular webapp"

  (
    cd .. || exit

    if [ -d "$WEBAPP_DIR" ]; then
      echo -e "$LOG_ERROR Cannot initialize Angular Webapp. Directory '$P$WEBAPP_DIR$D' already exists."
      echo -e "$LOG_ERROR Exit" && exit 8
    fi

    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      "$ANTORA_CLI" ng new "$WEBAPP_DIR"
  )
}

# @description Serve the Angular webapp on http://localhost:4200.
#
# @arg $1 string ``ng`` command - mandatory
# @exitcode 8 If param missing
function ng() {
  if [ -z "$1" ]
  then
    echo -e "$LOG_ERROR Param missing"
    echo -e "$LOG_ERROR exit" && exit 8
  fi

  (
    cd "../$WEBAPP_DIR" || exit

    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      --network host \
      "$ANTORA_CLI" ng "$1"
  )
}


echo -e "$LOG_INFO What should I do?"
select o in "$CMD_CLI_BUILD" "$CMD_NG_INIT" "$CMD_NG_SERVE" "$CMD_NG_TEST" "$CMD_NG_BUILD"; do
  case "$o" in
    "$CMD_CLI_BUILD" )
      echo -e "$LOG_INFO Lint dockerfile"
      docker run --rm -i hadolint/hadolint:latest < Dockerfile

      echo -e "$LOG_INFO Build this helper image"
      docker build -t "$ANTORA_CLI" .

      break;;
    "$CMD_NG_INIT" )
      initWebapp
      break;;
    "$CMD_NG_SERVE" )
      echo -e "$LOG_INFO Serve Angular webapp on http://localhost:4200"
      ng serve
      break;;
    "$CMD_NG_TEST" )
      echo -e "$LOG_INFO Execute the unit tests via Karma"
      ng test
      break;;
    "$CMD_NG_BUILD" )
      echo -e "$LOG_INFO Build Angular webapp"
      ng build

      (
        echo -e "$LOG_INFO Serve finished Angular build on http://localhost:4201"
        cd "../$WEBAPP_DIR" || exit
        docker run -it --rm -p 4201:80 -v "$(pwd)/dist/webapp":/usr/local/apache2/htdocs/ httpd:2.4
      )
      break;;
  esac
done
