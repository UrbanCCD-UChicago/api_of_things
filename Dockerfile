FROM ubuntu:xenial

ARG VERSION

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 MIX_ENV=prod

RUN mkdir /api_of_things
COPY . /api_of_things
WORKDIR /api_of_things

# install erlang 21.0

RUN apt-get update -qq && \
    apt-get install wget -y && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update -qq && \
    apt-get install esl-erlang=1:21.0 -y

# install elixir 1.8.1

RUN apt-get install build-essential -y && \
    apt-get install locales -y && \
    locale-gen "en_US.UTF-8" && \
    wget https://github.com/elixir-lang/elixir/archive/v1.8.1.tar.gz && \
    tar xzf v1.8.1.tar.gz && \
    cd elixir-1.8.1 && \
    make clean install && \
    cd .. && \
    rm v1.8.1.tar.gz && \
    rm -r elixir*

# install nodejs and yarn

RUN apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_10.x > setup_10.x && \
    bash setup_10.x && \
    apt-get update && \
    apt-get -y install nodejs && \
    npm install -g yarn && \
    rm setup_10.x

# install hex and npm dependencies

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    cd assets && \
    yarn install && \
    cd ..

# compile and digest all the things

RUN mix compile && \
    cd assets && \
    yarn run deploy && \
    cd .. && \
    mix phx.digest && \
    mix release --env=prod && \
    cd /api_of_things/_build/prod/rel/ && \
    mv aot $VERSION && \
    tar czf api_of_things-$VERSION.tar.gz $VERSION && \
    cd /api_of_things && \
    mv /api_of_things/_build/prod/rel/api_of_things-$VERSION.tar.gz .
