FROM ruby:2.5
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

# Remove out test and development dependencies by snipping them out
# below the `GEMFILE TRIM MARKER` line. See these issues for more info:
# - https://github.com/rubygems/bundler/issues/4552
# - https://github.com/rubygems/bundler/issues/2595
# We also place the gemfile into a location that won't be overwritten
# later by the source app COPY to preserve it.
RUN sed -i'' -e '/\= GEMFILE TRIM MARKER\ =/,$d' Gemfile && \
    cp Gemfile Gemfile.prod

# Speed up installs by running installs in parallel and install of
# nokogiri by telling it to use bundled system libs
# https://github.com/sparklemotion/nokogiri/blob/7d6690b/ext/nokogiri/extconf.rb#L72
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle config jobs 4

RUN bundle install --no-deployment --frozen --system

COPY . /app/

# Second overwrite of Gemfile since the previous COPY will overwrite our original
# edits and there's no thin-layer way to preserve the original. There may be a
# better way to do this but I was unable to find one.
RUN mv Gemfile.prod Gemfile
