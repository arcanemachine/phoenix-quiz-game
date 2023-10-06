import Config

# project
config :quiz_game,
  deployment_type: :test

# bcrypt - remove the complexity from the password hashing algorithm to make tests run faster
config :bcrypt_elixir, :log_rounds, 1

# database
database_name = System.get_env("POSTGRES_DB", "quiz_game") <> "_test"

config :quiz_game, QuizGame.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: database_name <> System.get_env("MIX_TEST_PARTITION", ""),
  ownership_timeout: 600_000,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# enable server for certain tasks, e.g. e2e testing
port = String.to_integer(System.get_env("PORT", "4000")) + 2

config :quiz_game, QuizGameWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: port],
  secret_key_base: "Sc0C7qslnaKDjL6J2AdMaGWo9Uip1P3gvoLul1nyZLl4Sx72E/eJAOnhQiohxw7w",
  server: false

# email - don't send email
config :quiz_game, QuizGame.Mailer, adapter: Swoosh.Adapters.Test

# logger - only print warnings and errors
config :logger, level: :warning

# oban
config :quiz_game, Oban, testing: :inline

# phoenix - initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# swoosh - disable API client
config :swoosh, :api_client, false
