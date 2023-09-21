defmodule QuizGame.Workers.DeleteOldRecords do
  @moduledoc "Deletes quiz records that are more than 30 days old."

  use Oban.Worker, queue: :default

  import Ecto.Query

  alias QuizGame.Repo
  alias QuizGame.Quizzes.Record

  @thirty_days 60 * 60 * 24 * 30

  @impl Oban.Worker
  def perform(_args) do
    now = DateTime.utc_now()
    Repo.delete_all(from r in Record, where: r.inserted_at < ^DateTime.add(now, -@thirty_days))

    :ok
  end
end
