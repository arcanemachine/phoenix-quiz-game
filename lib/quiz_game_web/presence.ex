defmodule QuizGameWeb.Presence do
  @moduledoc "Presence tracking for channels and processes."

  use Phoenix.Presence,
    otp_app: :quiz_game,
    pubsub_server: QuizGame.PubSub

  defmodule QuizData do
    @moduledoc false
    defstruct user: nil,
              display_name: nil,
              quiz_length: 0,
              quiz_state: :before_start,
              score: 0,
              current_card_index: 0
  end

  @spec track_data(pid(), String.t(), integer(), any()) ::
          {:error, any()} | {:ok, binary()}
  def track_data(pid, topic, quiz_id, %QuizData{} = data) do
    track(pid, topic, quiz_id, %{data: [data]})
  end

  @spec update_data(pid(), String.t(), integer(), any()) ::
          {:error, any()} | {:ok, binary()}
  def update_data(pid, topic, quiz_id, %QuizData{} = data) do
    update(pid, topic, quiz_id, %{data: [data]})
  end

  @doc "Lists all data being tracked via Presence for a given topic."
  @spec list_data_for(String.t(), integer()) :: list()
  def list_data_for(topic, quiz_id) do
    data = list(topic)

    data
    |> Map.get(to_string(quiz_id), %{metas: []})
    |> Map.get(:metas)
    |> data_from_metas
  end

  defp data_from_metas(metas) do
    Enum.map(metas, &get_in(&1, [:data]))
    |> List.flatten()
    |> Enum.uniq()
  end
end
