FROM vforgione/ubuntu-phoenix:21-1.8-10

ARG VERSION

ENV MIX_ENV=prod

RUN mkdir /api_of_things
COPY . /api_of_things
WORKDIR /api_of_things

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
