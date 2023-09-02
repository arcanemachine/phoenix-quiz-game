defmodule QuizGame.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuizGameWeb.Telemetry,
      QuizGame.Repo,
      {Phoenix.PubSub, name: QuizGame.PubSub},
      {Finch, name: QuizGame.Finch},
      QuizGameWeb.Presence,
      QuizGameWeb.Endpoint,
      {Oban, Application.fetch_env!(:quiz_game, Oban)}
    ]

    opts = [strategy: :one_for_one, name: QuizGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # update the endpoint configuration whenever the application is updated
  @impl true
  def config_change(changed, _new, removed) do
    QuizGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
