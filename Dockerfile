FROM ruby:2.2.5

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev

COPY app          /app/app
COPY bin          /app/bin
COPY config       /app/config
COPY conjur       /app/conjur
COPY db           /app/db
COPY lib          /app/lib
COPY log          /app/log
COPY public       /app/public
COPY spec         /app/spec
COPY tmp          /app/tmp
COPY vendor       /app
COPY config.ru    /app
COPY Gemfile      /app
COPY Gemfile.lock /app
COPY Rakefile     /app

EXPOSE 3030

WORKDIR /app

RUN bundle install

CMD ["/app/bin/rails", "s", "-p", "3030", "-b", "0.0.0.0"]