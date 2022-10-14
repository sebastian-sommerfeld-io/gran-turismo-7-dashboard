#
# Stage 1: build webapp docker image
#
# Make sure local/angular-cli:dev is available.
#
FROM local/angular-cli:dev AS build
LABEL maintainer="sebastian@sommerfeld.io"

USER ${UID}:${GID}

COPY ./ /angular/webapp
WORKDIR /angular/webapp

RUN npm install \
    && ng build

#
# Stage 2: run
#
# Run webserver with the Angular webapp (built in previous stage).
#
FROM httpd:2.4 AS run
LABEL maintainer="sebastian@sommerfeld.io"

RUN rm /usr/local/apache2/htdocs/index.html
COPY --from=build /angular/webapp/dist/webapp /usr/local/apache2/htdocs
