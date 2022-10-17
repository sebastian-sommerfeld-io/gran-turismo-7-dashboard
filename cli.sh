#!/bin/bash
# @file cli.sh
# @brief Build, run, control, etc. all components of this project.
#
# @description This script builds, runs, controls, etc. all components of this project.
#
# ==== Arguments
#
# The script does not accept any parameters.


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


CMD_NPM_INSTALL="INIT___install_node_modules"
CMD_NG_INIT="INIT___new_angular_project"
CMD_NG_LINT="RUN___ng_lint"
CMD_NG_SERVE="RUN___ng_serve"
CMD_BUILD="RUN___build_and_run_docker_image"

ANTORA_CLI_IMAGE="local/angular-cli:dev"

COMPONENTS_DIR="components"
WEBAPP_DIR="webapp"


# @description Initialize new angular project using ``ng new`` in ``components/webapp``.
#
# @exitcode 8 If ``components/webapp`` is already present. 
ng_init() {
  (
    cd "$COMPONENTS_DIR/angular-cli" || exit

    echo -e "$LOG_INFO Lint Dockerfile"
    docker run --rm -i hadolint/hadolint:latest < Dockerfile

    echo -e "$LOG_INFO Build Angular CLI helper image"
    docker build -t "$ANTORA_CLI_IMAGE" .
  )

  (
    cd "$COMPONENTS_DIR" || exit

    if [ -d "$WEBAPP_DIR" ]; then
      echo -e "$LOG_ERROR Cannot initialize Angular Webapp. Directory '$P$WEBAPP_DIR$D' already exists."
      echo -e "$LOG_ERROR Exit"
      echo -e "$LOG_WARN  +--------------------------------------------------------+"
      echo -e "$LOG_WARN  |                                                        |"
      echo -e "$LOG_WARN  |   Don't just delete the directory!                     |"
      echo -e "$LOG_WARN  |   Dockerfile is not part of project initialization!    |"
      echo -e "$LOG_WARN  |                                                        |"
      echo -e "$LOG_WARN  +--------------------------------------------------------+"
      exit 8
    fi

    echo -e "$LOG_INFO Initialize Angular webapp"
    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      "$ANTORA_CLI_IMAGE" ng new "$WEBAPP_DIR"
  )
}


# @description Wrap ``ng serve`` in function. Builds and serves your application, rebuilding
# on file changes.
ng_serve() {
  (
    cd "$COMPONENTS_DIR/$WEBAPP_DIR" || exit
    docker run --rm mwendler/figlet "    4200"

    echo -e "$LOG_INFO Serve Angular webapp on http://localhost:4200"
    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      --network host \
      "$ANTORA_CLI_IMAGE" ng serve
  )
}


# @description Run ``npm install`` in ``components/webapp``.
npm_install() {
  (
    cd "$COMPONENTS_DIR/$WEBAPP_DIR" || exit
    
    echo -e "$LOG_INFO Setup node modules (npm install)"
    docker run --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      node:18.9.0-bullseye-slim npm install
  )
}


# @description Build and run docker image using all services defined in components/docker-compose.yml.
build_and_run() {
  dockerfiles=(
    "$COMPONENTS_DIR/angular-cli/Dockerfile"
    "$COMPONENTS_DIR/$WEBAPP_DIR/Dockerfile"
  )
  for d in "${dockerfiles[@]}"
  do
    echo -e "$LOG_INFO Lint Dockerfile: $d"
    docker run --rm -i hadolint/hadolint:latest < "$d"
  done

  echo -e "$LOG_INFO Lint yaml"
  yamllint .

  (
    cd "$COMPONENTS_DIR" || exit
    docker run --rm mwendler/figlet "    4201"

    echo -e "$LOG_INFO Build and run app"
    # docker-compose build --no-cache
    docker-compose build
    docker-compose up --remove-orphans
  )
}


echo -e "$LOG_INFO What should I do?"
select o in "$CMD_NG_SERVE" "$CMD_BUILD" "$CMD_NG_INIT" "$CMD_NPM_INSTALL"; do
  case "$o" in
    "$CMD_NG_SERVE" )
      ng_serve
      break;;
    "$CMD_BUILD" )
      build_and_run
      break;;
    "$CMD_NG_INIT" )
      ng_init
      break;;
    "$CMD_NPM_INSTALL" )
      npm_install
      break;;
  esac
done
