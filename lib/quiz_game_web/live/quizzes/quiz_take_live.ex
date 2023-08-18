defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  import Ecto.Query
  import QuizGameWeb.Support, only: [get_record_or_404: 1]

  alias QuizGame.Quizzes.Quiz

  def get_quiz_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    get_record_or_404(query)
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = get_quiz_or_404(params)

    {:ok, socket |> assign(%{quiz: quiz, card: quiz.cards |> Enum.at(0)})}
  end

  # @impl Phoenix.LiveView
  # def mount(_params, _session, socket) do
  #   {:ok, socket}
  # end
end
