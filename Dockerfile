FROM ruby:3.0.0-alpine

WORKDIR /home/app

# https://nokogiri.org/tutorials/installing_nokogiri.html#ruby-on-alpine-linux-docker_1
# Install dependencies really needed for running it.
# - postgresql-client; needed for pg
# - tzdata; needed for pg
# - nodejs, yarn; needed for webpacker
# - less; needed for pry, https://github.com/pry/pry/issues/1248#issuecomment-366056015
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    nodejs \
    yarn \
    less

COPY ./Gemfile* ./

# Install dependencies needed only needed for installing it,
# and uninstall them right after `bundle install`, on the same build step.
RUN apk add --no-cache --virtual .rails-temporary-native-deps \
    build-base \
    postgresql-dev && \
  bundle install && \
  rm -rf $GEM_HOME/cache && \
  apk del .rails-temporary-native-deps

COPY ./package.json ./yarn.lock ./

RUN yarn install && yarn cache clean

COPY . .
