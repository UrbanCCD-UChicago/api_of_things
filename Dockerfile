FROM ubuntu:xenial

# ensure tag
ARG tag

# install erlang 21.0

RUN apt-get update -qq
RUN apt-get install wget -y
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update -qq
RUN apt-get install esl-erlang=1:21.0 -y

# install elixir 1.7.0

RUN apt-get install build-essential -y
RUN apt-get install locales -y
RUN locale-gen "en_US.UTF-8"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN wget https://github.com/elixir-lang/elixir/archive/v1.7.0.tar.gz
RUN tar xzf v1.7.0.tar.gz
RUN cd elixir-1.7.0 && make clean install && cd ..
RUN elixir -v

# clone repo down

RUN apt-get install git -y
RUN git clone --branch v$tag --depth 1 https://github.com/UrbanCCD-UChicago/api_of_things.git
WORKDIR api_of_things/

# install dependencies

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
