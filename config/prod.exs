import Config

# include the path to a cache manifest containing the digested version of static files
config :quiz_game, QuizGameWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# logger: do not print debug messages in production
config :logger, level: :info

# swoosh
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: QuizGame.Finch

# swoosh - disable local memory storage
config :swoosh, local: false
