defmodule QuizGameWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :quiz_game,
    pubsub_server: QuizGame.PubSub

  alias QuizGameWeb.Presence

  @quiz_user_count_topic "quiz_user_count"

  def track_quiz_user(pid, quiz_id, display_name) do
    Presence.track(pid, @quiz_user_count_topic, quiz_id, %{users: [%{display_name: display_name}]})
  end

  def list_quiz_users() do
    Presence.list(@quiz_user_count_topic) |> Enum.map(&extract_users/1)
  end

  defp extract_quiz_users({display_name, %{metas: metas}}) do
    {display_name, quiz_users_from_metas_list(metas)}
  end

  defp quiz_users_from_metas_list(metas_list) do
    Enum.map(metas_list, &get_quiz_user_count_from_meta_map/1) |> List.flatten() |> Enum.uniq()
  end

  defp get_quiz_user_count_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
