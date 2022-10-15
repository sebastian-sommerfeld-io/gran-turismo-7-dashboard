#!/bin/bash
# @file cli.sh
# @brief Build, run, control, etc. all components of this project.
#
# @description This script builds, runs, controls, etc. all components of this project.
#
# ==== Arguments
#
# The script does not accept any parameters.


CMD_NG_SERVE="angular___serve"
CMD_BUILD="build_and_run"

ANTORA_CLI_IMAGE="local/angular-cli:dev"

COMPONENTS_DIR="components"
WEBAPP_DIR="webapp"


echo -e "$LOG_INFO What should I do?"
select o in "$CMD_NG_SERVE" "$CMD_BUILD"; do
  case "$o" in

    "$CMD_NG_SERVE" )
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

      break;;

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

      (
        cd "$COMPONENTS_DIR" || exit
        docker run --rm mwendler/figlet "    4201"

        echo -e "$LOG_INFO Build and run app"
        # docker-compose build --no-cache
        docker-compose build
        docker-compose up --remove-orphans
      )

      break;;
  esac
done
