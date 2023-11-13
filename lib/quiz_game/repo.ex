defmodule QuizGame.Repo do
  use Ecto.Repo,
    otp_app: :quiz_game,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @doc """
  Shows the number of objects in a given table.

  ## Examples

      iex> count("users")
  """
  def count(table_name), do: one(from t in table_name, select: count(t.id))
end
