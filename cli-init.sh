#!/bin/bash
# @file cli-init.sh
# @brief Initialize this project.
#
# @description This script initializes this project and creates all Angular files.
#
# ==== Arguments
#
# The script does not accept any parameters.


ANTORA_CLI_IMAGE="local/angular-cli:dev"

COMPONENTS_DIR="components"
WEBAPP_DIR="webapp"


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