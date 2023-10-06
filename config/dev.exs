import Config

config :quiz_game,
  deployment_type: :dev

# database
database_name = System.get_env("POSTGRES_DB", "quiz_game") <> "_dev"

config :quiz_game, QuizGame.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: database_name,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# configure endpoint (disable caching; enable debugging and code reloading; configure watchers
port = String.to_integer(System.get_env("PORT", "4000")) + 1

config :quiz_game, QuizGameWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: port, protocol_options: [idle_timeout: 5_000_000]],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "V24R3djVtlODFoK6OEtzvYffLE/w4dRquS/5u/UvDnEpKqn1xbWIs+HOyfMMUbHZ",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# live reload - watch static files and templates
config :quiz_game, QuizGameWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/quiz_game_web/.*/(html/|live/|components).*(ex|heex|js)$",
      ~r"lib/quiz_game_web/layouts.*(ex|heex)$"
    ]
  ]

# logger - do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# plug - initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# phoenix: stacktrace - set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# phoenix: dev routes - enable dev routes in router (e.g. dashboard, mailbox)
config :quiz_game, dev_routes: true

# swoosh - disable swoosh API client during development
config :swoosh, :api_client, false
