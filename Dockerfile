FROM ruby:2.2.5

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev

RUN mkdir /app
WORKDIR /app

COPY . .

EXPOSE 3030

RUN bundle install

CMD ["/app/bin/rails", "s", "-p", "3030", "-b", "0.0.0.0"]
