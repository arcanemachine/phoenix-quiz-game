set dotenv-load

# NOTES #
# - Prepend a statement with '!' to ignore errors in a line's exit code

@_default:
  # list all the commands in this justfile
  just --list -u


# VARIABLES #
default_cpu_arch := "x86_64"
newest_supported_otp := "26.0.2"
image_name := "arcanemachine/phoenix-quiz-game"

# colors
color_error := "\\033[91m"
color_info := "\\033[96m"
color_success := "\\033[32m"
color_reset := "\\033[39m"


# SHORTCUTS #
@SHORTCUTS_____________________:
  echo "This command doesn't do anything. It's used as a separator when listing the 'just' commands."

# run a postgres container
@postgres:
  docker run --name postgres --rm -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres} -p 5432:5432 -v postgres:/var/lib/postgresql/data postgres

# run basic setup steps via 'mix setup'
@setup:
  echo "Running basic setup procedure via 'mix setup'...";
  mix setup

# start a dev server (server-dev-start-interactive)
@dev: server-dev-start-interactive

# start a dev server (server-dev-start-interactive)
@start: dev

# reset the database
@reset: db-reset

# run all tests (test-elixir)
@test:
  just test-elixir
  just _echo_success "All tests completed successfully"

# create a release (elixir-release-create)
@release: elixir-release-create

# start a prod server (server-prod-migrate + server-dev-start)
@prod: server-prod-migrate server-prod-start

# create a release and build a docker image (docker-build)
@build: docker-build

# push the image to docker hub (docker-push)
@push: docker-push

# almost one-liner to deploy a release (must still use ansible playbook to push to server) (test + release + build + push)
@deploy:
  @./support/scripts/deploy
  just _echo_success "done"

# COMMANDS #
@COMMANDS______________________:
  echo "This command doesn't do anything. It's used as a separator when listing the 'just' commands."

# remove stale versions of static assets
@assets-prune:
  echo "Pruning digested assets..."
  @mix phx.digest.clean --all

# copy caddyfile, then validate and reload caddy [environment: dev|vagrant|staging|prod]
@caddyfile-copy-validate-reload environment:
  echo "Copying the Caddyfile, then validating and reloading Caddy..."
  @./support/scripts/caddyfile-copy-validate-reload {{ environment }}

# create the database with 'mix' and run initial migrations
@db-setup:
  echo "Setting up the database..."
  @mix ecto.setup

# create the database with 'mix'
@db-create:
  echo "Creating the database..."
  @mix ecto.create

# run database migrations with 'mix'
@db-migrate:
  echo "Running database migrations..."
  @mix ecto.migrate

# drop the database with 'mix'
@db-drop:
  echo "Dropping the database..."
  @mix ecto.drop

# reset the database with 'mix'
@db-reset:
  echo "Resetting the database..."
  @mix ecto.reset

# run an action on a postgres container [action (default: 'up')]
@docker-postgres action="up":
  echo "Running the '{{ action }}' action on a Postgres container..."
  ./support/scripts/containers/compose--postgres {{ action }}

# build a docker image
@docker-build image_name=image_name:
  echo "Building a Docker image '{{ image_name }}'..."

  # build untagged image
  @docker build -t {{ image_name }} .

  # build an architecture-specific image
  printf "\n\{{ color_info }}Building '$(uname -m)' image...{{ color_reset }}\n\n"
  docker build -t "{{ image_name }}:$(uname -m)" .

  # build versioned image
  just _echo_info "NOTE: The versioned image may fail to build the first time. Try running the same command again if it fails."
  just _echo_info "Building a versioned image..."
  docker build -t "{{ image_name }}:$(just version-project)-erlang-$(just version-otp)-$(uname -m)" .

  # build 'latest' image if we are on the 'x86_64' CPU architecture
  if [ "$(uname -m)" = "{{ default_cpu_arch }}" ] && \
     [ "$(just version-otp)" = "{{ newest_supported_otp }}" ]; then \
    just _echo_info "Building the 'latest' image since we're using the default CPU architecture ({{ default_cpu_arch }}) architecture and our latest supported version of OTP ({{ newest_supported_otp }})..."; \
    docker build -t "{{ image_name }}:latest" .; \
  fi

# push container image to Docker Hub
@docker-push image_name=image_name:
  echo "Pushing image(s) to Docker Hub..."

  # push architecture-specific image to Docker Hub
  just _echo_info "Pushing architecture-specific image to Docker Hub..."
  @docker push "{{ image_name }}:$(uname -m)"

  # push versioned image to Docker Hub
  just _echo_info "Pushing versioned image to Docker Hub..."
  @docker push "{{ image_name }}:$(just version-project)-erlang-$(just version-otp)-$(uname -m)"

  # push 'latest' image to Docker Hub if we are on the 'x86_64' CPU architecture
  if [ "$(uname -m)" = "{{ default_cpu_arch }}" ] && [ "$(just version-otp)" = "{{ newest_supported_otp }}" ]; then \
    just _echo_info "Updating the 'latest' image on Docker Hub since we're using the default CPU architecture ({{ default_cpu_arch }}) architecture and our latest supported version of OTP ({{ newest_supported_otp }})..."; \
    docker push '{{ image_name }}:latest'; \
  fi

# generate environment file [args (e.g.): --help]
@dotenv-generate args="":
  echo "Generating new environment file..." > /dev/stderr
  @./support/scripts/dotenv-generate {{ args }}

# fetch Elixir dependencies
@elixir-dependencies-fetch:
  echo "Fetching Elixir dependencies..."
  @mix deps.get

# get info about an Elixir Hex package
@elixir-package-info package_name:
  echo "Checking for info about the '{{ package_name }}' Hex package..."
  @mix hex.info {{ package_name }}

# upgrade a specific Elixir Hex package
@elixir-package-upgrade package_name:
  echo "Upgrading Elixir Hex package '{{ package_name }}'..."
  @mix deps.update {{ package_name }}

# upgrade all Elixir dependencies
@elixir-package-upgrade-all:
  echo "Upgrading all Elixir dependencies..."
  @mix deps.update --all

# check for Elixir Hex package updates
@elixir-package-update-list:
  echo "Listing Elixir package updates..."
  @! mix hex.outdated

# create a release
@elixir-release-create:
  echo "Creating an Elixir release..."
  @./support/scripts/elixir-release-create

# generate a grafana dashboard for a given prom_ex plugin [plugin_name (e.g.): application|beam|...]
@grafana-dashboard-generate plugin_name:
  mix prom_ex.dashboard.export --dashboard {{ plugin_name }}.json --stdout

# install JS dependencies via 'npm'
@js-dependencies-install:
  echo "Installing JS dependencies via 'npm'..."
  cd assets && npm install

# run pre-commit hooks (must have 'pre-commit' installed)
@pre-commit:
  echo "Running pre-commit hooks..."
  @pre-commit run --all-files

# start a dev server
@server-dev-start:
  echo "Starting a dev server..."
  mix phx.server

# start an interactive dev server with shell/debugging capabilities
@server-dev-start-interactive:
  echo "Starting an interactive dev server with shell/debugging capabilities..."
  iex -S mix phx.server

# run migrations on the prod server
@server-prod-migrate:
  echo "Running migrations on the prod server..."
  @./_build/prod/rel/quiz_game/bin/migrate

# start the prod server
@server-prod-start:
  echo "Starting prod server..."
  @./_build/prod/rel/quiz_game/bin/server

# stop the prod server
@server-prod-stop:
  echo "Stopping prod server..."
  @./_build/prod/rel/quiz_game/bin/quiz_game stop

# spawn an IEx shell
@shell:
  echo "Spawning IEx shell...";
  iex -S mix

# run Elixir tests
@test-elixir args='':
  echo "Running Elixir tests..."
  @./support/scripts/test-elixir {{ args }}

# run Elixir tests (in watch mode)
@test-elixir-watch args='':
  echo "Running Elixir tests in watch mode..."
  @./support/scripts/test-elixir-watch {{ args }}

# print the OTP version number
@version-otp:
  erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell

# print the project version number
@version-project:
  mix eval 'IO.puts(QuizGame.MixProject.project[:version])'

# PRIVATE HELPERS #
@_echo_error val:
  echo "{{ color_error }}Error: {{ val }}{{ color_reset }}"

@_echo_info val:
  echo "{{ color_info }}{{ val }}{{ color_reset }}"

@_echo_success val:
  echo "{{ color_success }}{{ val }}{{ color_reset }}"
