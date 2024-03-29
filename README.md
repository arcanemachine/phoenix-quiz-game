# phoenix-quiz-game

[View Live Demo](https://phoenix-quiz-game.nicholasmoen.com/)

---

**All commands in this document should be performed from the project root directory.**

---

A game that allows you (e.g. teacher) to generate quizzes, and supervise your users (e.g. students) as they take the test.

Also good for generating random math quizzes for you to brush up on your arithmetic.

Made using the [Phoenix web framework](https://www.phoenixframework.org/), and enhanced with [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view).

Features:

- Basic CRUD
- LiveView CRUD
- A comprehensive suite of Elixir tests (including doctests, where appropriate)
- Admin interface via [Kaffy](https://github.com/aesmail/kaffy)
- Job queueing via [Oban](https://github.com/sorentwo/oban)
- HCaptcha integration via [hcaptcha](https://github.com/sebastiangrebe/hcaptcha)
- Releases (vanilla/Docker/fly.io)
  - Supports `x86_64` + `aarch64` (`ARM64v8`) Docker images
- Supports a variety of container-based environments using Docker/Podman
- EditorConfig (standardizes file formatting: spaces per line, etc.)
- Enforces standardized commit messages with [`git-conventional-commits`](https://github.com/qoomon/git-conventional-commits)
- Uses [`just`](https://github.com/casey/just) task runner
  - Run `just` by itself to see the list of available commands.

## Getting Started

First, you'll need to clone this repo: `git clone https://github.com/arcanemachine/phoenix-quiz-game`

### Working in a `dev` Environment

NOTE: In order to do things via `just`, you will need to install the [`just`](https://github.com/casey/just) task runner.

- Setup your local environment variables:
  - Via `just`: `just dotenv-generate`
  - Manually:
    - Run the `./support/scripts/dotenv-generate` script to generate a `.env` file to get you started.
      - You can set custom/private environment variables in `.env` so that they will not be accidentally committed to source control.
  - Load the environment variables into the current terminal session: `. .env`
    - NOTE: [`direnv`](https://direnv.net/) is a great tool to automatically source environment files on a per-project basis.
- Install the `npm` dependencies:
  - Via `just`: `just js-dependencies-install`
  - Manually:
    - Ensure that `npm` is installed and working on your computer.
    - Navigate to the directory `assets/` and run `npm install`.
- Ensure that a Postgres server is running:
  - Via `just`: `just postgres` (must have Docker installed).
  - Manually:
    - Ensure the Postgres server is installed and running in your desired location, and [ensure that your Phoenix application can access the database](https://hexdocs.pm/phoenix/up_and_running.html).
- Setup the server:
  - Via `just`: `just setup`
  - Manually:
    - Run `mix deps.get` to fetch the dependencies.
    - Setup the database: `mix ecto.setup`
- Run the server:
  - Via `just`: `just start`
  - The manual way: `mix phx.server`
- Your server should now be accessible on `localhost:4001`.
  - It may take a moment for `esbuild` to build its initial bundle.
    - The layout of the page will look ugly while this is happening.
  - This project's ports are set by configuring the `PORT` environment variable (e.g. in the `.env` file).
    - Production: The default port is `PORT` (e.g. 4000)
    - Development: The default port is `PORT + 1` (e.g. 4001)
    - Testing: The default port is `PORT + 2` (e.g. 4002)

### Testing

Before running any tests, make sure that you have followed the instructions in the above section "Getting Started".

Notes:

- To run all tests at once, run `just test`.
  - The first test run may appear to hang when the console says `Resetting the database...`.
    - Elixir may need a minute or two to compile dependencies for the `test` `MIX_ENV`.
- A Postgres server must be running for the tests to pass.
  - You may need to create a test database: `MIX_ENV=test mix ecto.create`
  - If any errors occur during the tests, try resetting the test database: `MIX_ENV=test mix ecto.reset`
    - For example, the E2E test scripts reset the database between test runs. However, if the script is aborted, the database may not be reset, which can effect the results of `mix test`.

#### Elixir-Based Tests

Run the Elixir-based tests using any of these commands:

- `just test-elixir` - Use the `just` task runner to run the tests
- `mix test` - The regular method of running the tests.
- `./support/scripts/test-elixir` - A convenience script for running the Elixir tests.
  - This script clears the test database before running the tests. This prevents any issues that may be caused when the test database is not cleared, e.g. during failed E2E test run.
- `./support/scripts/test-elixir-watch` - A convenience script for running the Elixir-based tests in watch mode.

Note:

- The first test run may appear to hang when the console says `Resetting the database...`.
  - Elixir may need a minute or two to compile dependencies for the `test` `MIX_ENV`.

### Releases

Releases can be created for either a vanilla/bare metal deployment, or for a Docker-based deployment.

#### Creating a Release

##### First Steps

Before you create a release, ensure that your environment variables are set correctly. You can use `direnv` to easily load your environment when navigating within this project's directories.

Navigate to the project root directory and set up your environment variables:

- You can set custom/private environment variables in `.env` so that they will not be accidentally committed to source control
  - Use the environment generator script to generate a `.env` file in the project root directory. You can modify this `.env` file as needed.
    - To run the script:
      - `./support/scripts/dotenv-generate`
      - Or, `just dotenv-generate`

##### Vanilla/Bare Metal Deployment

Run the following commands from the project root directory:

- Create a release using the helper script:
  - `./support/scripts/elixir-release-create`
- Make sure that Postgres is running:
  - Use `pg_isready`:
    - e.g. `pg_isready` or `pg_isready -h localhost` or `pg_isready -h your-postgres-ip-address-or-domain`
- Set up the database in Postgres:
  - Spawn a shell as the `postgres` user:
    - `sudo -iu postgres`
  - Open the Postgres terminal:
    - `psql -U postgres`
  - Create a new database user:
    - `CREATE USER your_postgres_user WITH PASSWORD 'your_postgres_password';`
  - Create the database and grant privileges to the new user:
    - `CREATE DATABASE quiz_game;`
    - `GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;`
  - Exit the Postgres prompt:
    - `\q`
- Set up the Phoenix server:
  - Run migrations:
    - `MIX_ENV=prod ./_build/prod/rel/quiz_game/bin/migrate`
  - Start the server:
    - `MIX_ENV=prod PHX_SERVER=true ./_build/prod/rel/quiz_game/bin/server`

##### Docker/Podman Deployment

When using Podman, you can use `podman-compose` to manage your multi-container services.

However, `podman-compose` may have issues under certain circumstances (e.g. I have run into issues with it on `aarch64` systems). To resolve this issue, `docker-compose` can be configured as a drop-in replacement for `podman-compose`.

Note that `docker-compose` must be configured (instructions below) to use the Podman socket instead of the default Docker socket.

###### Using `docker-compose` With Podman

NOTE: In order for this to work, you will need to install an older version of `docker-compose`. It is not unreasonable to assume this situation will stop working at some point in the future. For now, I find it to be a useful workaround when `podman-compose` isn't yet up to the task.

- Install `docker-compose` v1.29.2: `sudo apt install docker-compose`
  - Note: `docker-compose` v2 has been re-written in Go and is not compatible with Podman as of this writing. v1.29.2 is the last version currently supported.
- Set the socket path when running `docker-compose` commands:
  - With an environment variable: `DOCKER_HOST="unix:$(podman info --format '{{.Host.RemoteSocket.Path}}')" docker-compose up`
  - Or, with the `-H` flag: `docker-compose -H "unix:$(podman info --format '{{.Host.RemoteSocket.Path}}')" up`

###### Building a Release as a Docker Image

Run the following commands from the project root directory:

- Create a release using the helper script:
  - `./support/scripts/elixir-release-create`
  - Or, `just release`
- Build a container image:
  - Docker: `docker build -t quiz-game .`
  - Podman: `podman build -t quiz-game .`

To push an image to Docker Hub:

- Ensure that you have built an image using the instructions above.
- Login to your Docker Hub account:
  - Examples:
    - Docker: `docker login`
    - Podman: `podman login docker.io`
  - If you have 2FA enabled, you may need to login using an [Access Token](https://hub.docker.com/settings/security) instead of a password.
    - Docker will notify you when attempting to login with a password, but Podman will fail silently.
- Push the image to Docker Hub:
  - Docker: `docker push arcanemachine/quiz-game`
  - Podman: `podman push arcanemachine/quiz-game`

###### Building an `aarch64` Image

To build an `aarch64` (a.k.a `ARM64`/`armv8`/`arm64v8`) image, follow the instructions in the previous section, but do so from an `aarch64` machine. This will produce an `aarch64`-compatible image.

`aarch64` images are tagged with the `aarch64` tag, e.g. `docker.io/arcanemachine/quiz-game:aarch64`.

When generating a dotenv file, the generator script will detect your CPU architecture (`x86_64` or `aarch64`) so you automatically pull the proper image when using the deployment scripts in `./support/scripts/`.

Note to self: Use this command to build an `aarch64` image: `docker build -t arcanemachine/phoenix-quiz-game:aarch64 .`

###### Running a Basic Phoenix Container

**Using a Locally-Built Image**

A basic `compose.yaml` file can be found in the project root directory. It exposes a plain Phoenix container.

To run this barebones container, run the following commands from the project root directory:

- First, ensure that you have a Postgres server running locally.
- [Build the Docker image](#building-a-release-as-a-docker-image).
- Run the Compose file:
  - Docker: `docker compose up`
  - Podman: `podman-compose up`

**Using the Docker Hub Image**

Run the following command from the project root directory:

- Docker: `docker compose -f support/containers/compose.phoenix.yaml up`
- Podman: `podman-compose -f support/containers/compose.phoenix.yaml up`

**Running an `aarch64` Container**

This project supports the creation and use of containers for the `x86_64` and `aarch64` CPU architectures.

- The default container image tag on Docker Hub (`latest`) supports the `x86_64` architecture.
- The `aarch64` image tag for this project on Docker Hub supports the `aarch64` architecture.
  - e.g. `docker.io/arcanemachine/quiz-game:aarch64`
- To use the `aarch64` container with this project's compose files (located in `support/containers/`), ensure the `IMAGE_TAG` environment variable is set to `aarch64`:
  - Examples:
    - Docker: `IMAGE_TAG=aarch64 docker compose -f support/containers/compose.phoenix.yaml up`
    - Podman: `IMAGE_TAG=aarch64 podman-compose -f support/containers/compose.phoenix.yaml up`
  - NOTE: The generated `.env` file (created by running `just dotenv-generate`) should have the proper CPU architecture for your machine in the `IMAGE_TAG` variable.

###### Other Docker/Podman Deployment Procedures

For other Docker/Podman container procedures, see `/support/containers/README.md`.

### Remote Deployment

#### Fly.io

Before continuing, ensure that [`flyctl`](https://fly.io/docs/hands-on/install-flyctl/) is installed.

To deploy via fly.io, you must use the Dockerfile in the `support/` directory. The Dockerfile in the project root directory is just a symlink, so you can safely delete it and symlink the Fly Dockerfile there instead:

- `rm ./Dockerfile && ln -s support/containers/Dockerfile.fly Dockerfile`

The `fly.io` Dockerfile is essentially the same as the default Dockerfile generated by Phoenix, but has a few additions to make it work with `fly.io`. These additions are created when creating the project with `flyctl`.

- NOTE: The default Dockerfile generated by `flyctl` may have some issues with Tailwind and other NPM dependencies. The modified Dockerfiles used in this project have a few modifications designed to mitigate this.

This project has a `fly.toml` file. To create a new one, run `fly launch` and follow the prompt.

To deploy the project, run `flyctl deploy`.

### Locations of Dependencies

There are several types of dependencies throughout this project that should be kept up to date:

- Elixir:
  - `mix.exs`
  - `config/config.exs`: `esbuild`, `tailwind`
- Javascript (npm):
  - `assets/js/`
- Containers (Docker/Podman):
  - `./support/containers/compose.*.yaml`
  - `./support/containers/Dockerfile.*`
