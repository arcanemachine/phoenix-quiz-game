defmodule QuizGame.Repo do
  use Ecto.Repo,
    otp_app: :quiz_game,
    adapter: Ecto.Adapters.Postgres
end
