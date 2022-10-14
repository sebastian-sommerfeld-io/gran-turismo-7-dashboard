#!/bin/bash
# @file cli.sh
# @brief Build, run, control, etc. all components of this project.
#
# @description This script builds, runs, controls, etc. all components of this project.
#
# ==== Arguments
#
# The script does not accept any parameters.


CMD_NG_INIT="webapp___init"
CMD_NG_SERVE="webapp___serve_dev"
CMD_BUILD="build_and_run"

ANTORA_CLI_IMAGE="local/angular-cli:dev"

COMPONENTS_DIR="components"
WEBAPP_DIR="webapp"


echo -e "$LOG_INFO What should I do?"
select o in "$CMD_NG_INIT" "$CMD_NG_SERVE" "$CMD_BUILD"; do
  case "$o" in

    #
    # Initialize Angular webapp
    #
    "$CMD_NG_INIT" )
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
          echo -e "$LOG_ERROR Exit" && exit 8
        fi

        echo -e "$LOG_INFO Initialize Angular webapp"
        docker run --rm \
          --volume "$(pwd):$(pwd)" \
          --workdir "$(pwd)" \
          "$ANTORA_CLI_IMAGE" ng new "$WEBAPP_DIR"
      )

      echo -e "$LOG_INFO Initialize Angular webapp"

      break;;
    
    #
    # Serve Angular webapp in development webserver
    #
    "$CMD_NG_SERVE" )
      (
        cd "$COMPONENTS_DIR/$WEBAPP_DIR" || exit

        echo -e "$LOG_INFO Serve Angular webapp on http://localhost:4200"
        docker run --rm \
          --volume "$(pwd):$(pwd)" \
          --workdir "$(pwd)" \
          --network host \
          "$ANTORA_CLI_IMAGE" ng serve
      )

      break;;

    #
    # Build and run full application
    #
    "$CMD_BUILD" )
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

      echo -e "$LOG_INFO Build and run app"
      docker-compose build --no-cache

      docker run --rm mwendler/figlet "    4201"

      docker-compose up --remove-orphans

      break;;
  esac
done
