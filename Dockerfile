FROM ruby:3.3
MAINTAINER CyberArk Software Ltd.

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y build-essential \
                       libpq-dev \
                       zip

RUN mkdir /app
WORKDIR /app

COPY Gemfile \
     Gemfile.lock /app/

# Speed up installs by running installs in parallel and install of
# nokogiri by telling it to use bundled system libs
# https://github.com/sparklemotion/nokogiri/blob/7d6690b/ext/nokogiri/extconf.rb#L72
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle config jobs 4

# Exclude 'development' and 'test' dependency groups when building the
# base/production Service Broker image.
RUN bundle config set --local frozen 'true' && \
    bundle config set --local system 'true' && \ 
    bundle config set --local without 'development test' && \
    bundle config set --local deployment 'false' && \
    bundle install

COPY . /app/
