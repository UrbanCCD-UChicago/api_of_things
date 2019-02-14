![logo](./assets/static/images/logo.png)

The API of Things is the **official** API for the Array of Things project.

## Development

### Installing the dependencies

This project requires Erlang 21.2.4, Elixir 1.8 and NodeJS 10.15.1. I **highly** recommend using [asdf](https://github.com/asdf-vm/asdf) to install and manage environments. I would also encourage you to use yarn to manage the JS assets.

```bash
$ asdf install                        # reads the .tool-versions file in the repo
$ npm install -g yarn                 # globally install yarn
$ cd assets && yarn install && cd ..  # install the js deps
$ mix do deps.get, compile            # install the ex deps and compiles the app
```

### Starting the database

The API relies on 2 Postgres extensions: PostGIS and TimescaleDB. Both of which are a total pain to get installed on various systems. Luckily, the good people who develop TimescaleDB released a Docker image with their extension as well as PostGIS preloaded.

All you need to do to get it is:

```bash
$ docker pull timescale/timescaledb-postgis
```

And to run it (daemonized):

```bash
$ docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=password timescale/timescaledb-postgis
```

### Seeding the database

To create, migrate and seed the database:

```bash
$ mix ecto.setup
```

If you find yourself in a situation where you want a clean slate, you can run:

```bash
$ mix ecto.reset
```

### Running the server application

To run the application server:

```bash
$ mix phx.server
```

### Running an interactive terminal

To get a shell with the app code loaded:

```bash
$ iex -S mix
```

This will load the entire project and read in the contents of `.iex.exs`.

### Running the test suite

To run the tests:

```bash
$ mix test
```