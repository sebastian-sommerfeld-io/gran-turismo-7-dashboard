FROM node:18.9.0-bullseye-slim
LABEL maintainer="sebastian@sommerfeld.io"

ARG UID=1000
ARG GID=1000

RUN npm install --location=global @angular/cli@13.3.9

USER ${UID}:${GID}
