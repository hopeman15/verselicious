FROM ruby:4.0-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /action

COPY Gemfile verselicious.gemspec ./
COPY lib/verselicious/version.rb lib/verselicious/version.rb
RUN bundle install --without development test

COPY lib/ lib/
COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
