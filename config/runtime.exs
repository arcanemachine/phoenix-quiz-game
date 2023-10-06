import Config

# project
config :quiz_game,
  email_recipient_contact_form:
    System.get_env("EMAIL_RECIPIENT_CONTACT_FORM", "arcanemachine@tutanota.com")

# hcaptcha
config :hcaptcha,
  public_key: System.get_env("HCAPTCHA_PUBLIC_KEY") || false,
  secret: System.get_env("HCAPTCHA_PRIVATE_KEY") || false

if System.get_env("PHX_SERVER") do
  config :quiz_game, QuizGameWeb.Endpoint, server: true
end

if config_env() == :test do
  # do not display the captcha when running elixir tests
  config :hcaptcha,
    public_key: false,
    secret: false
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :quiz_game, QuizGame.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :quiz_game, QuizGameWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0},
      # ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  if System.get_env("AWS_SECRET", "") != "" do
    # use live email adapter if Amazon SES settings are configured
    config :quiz_game, QuizGame.Mailer,
      adapter: Swoosh.Adapters.AmazonSES,
      region: System.fetch_env!("AWS_REGION"),
      access_key: System.fetch_env!("AWS_ACCESS_KEY"),
      secret: System.fetch_env!("AWS_SECRET")
  end
end
