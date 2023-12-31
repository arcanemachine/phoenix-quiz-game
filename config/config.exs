import Config

# project
config :quiz_game,
  project_name: "Quiz Game"

# ecto
config :quiz_game,
  ecto_repos: [QuizGame.Repo]

# endpoint
config :quiz_game, QuizGameWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: QuizGameWeb.ErrorHTML, json: QuizGameWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: QuizGame.PubSub,
  live_view: [signing_salt: "L/HSIeMt"]

# esbuild
config :esbuild,
  version: "0.18.20",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# json
config :phoenix, :json_library, Jason

# kaffy
config :kaffy,
  otp_app: :quiz_game,
  ecto_repo: QuizGame.Repo,
  router: QuizGameWeb.Router

# logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# mailer
config :quiz_game, QuizGame.Mailer, adapter: Swoosh.Adapters.Local

config :quiz_game, Oban,
  repo: QuizGame.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"@daily", QuizGame.Workers.DeleteOldRecords}
     ]}
  ],
  queues: [default: 10]

# tailwind
config :tailwind,
  version: "3.3.3",
  default: [
    args: ~w(
      --config=tailwind.config.cjs
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# environment (must be at the bottom so that overrides work properly)
import_config "#{config_env()}.exs"
