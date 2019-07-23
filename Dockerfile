FROM jenkins/jnlp-slave:alpine

USER root
RUN sed -i -e 's/v3\.9/v3.10/g' /etc/apk/repositories

RUN apk update

# Install latest nodejs  
RUN apk add --update nodejs nodejs-npm

# Install dependencies of canvas needed to build webpack
RUN apk add --update \
    && apk add --no-cache ffmpeg opus pixman cairo pango giflib ca-certificates \
    && apk add --no-cache --virtual .build-deps git curl build-base jpeg-dev pixman-dev \
    cairo-dev pango-dev pangomm-dev libjpeg-turbo-dev giflib-dev freetype-dev python g++ make nodejs npm chromium jq
