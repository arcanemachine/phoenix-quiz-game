defmodule QuizGameWeb.Presence do
  @moduledoc "Presence tracking for channels and processes."

  use Phoenix.Presence,
    otp_app: :quiz_game,
    pubsub_server: QuizGame.PubSub

  # @quiz_presence_topic "quiz_presence"

  @spec track_user(pid(), String.t(), integer(), String.t()) :: {:error, any()} | {:ok, binary()}
  def track_user(pid, topic, quiz_id, user) do
    track(pid, topic, quiz_id, %{users: [user]})
  end

  @spec list_users_for(String.t(), integer()) :: List.t()
  def list_users_for(topic, quiz_id) do
    users = list(topic)

    users
    |> Map.get(to_string(quiz_id), %{metas: []})
    |> Map.get(:metas)
    |> users_from_metas
  end

  defp users_from_metas(metas) do
    Enum.map(metas, &get_in(&1, [:users]))
    |> List.flatten()
    # |> Enum.map(&Map.get(&1, :email))
    |> Enum.uniq()
  end
end
