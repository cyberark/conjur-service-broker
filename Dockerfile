FROM ruby:2.2.5

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN bundle install