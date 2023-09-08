defmodule QuizGameWeb.Quizzes.CardLive.Index do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.{Card, Quiz}
  alias QuizGame.Repo

  @impl true
  def mount(params, session, socket) do
    quiz = _get_quiz_or_404(params)

    {:ok, socket |> assign(quiz: quiz) |> stream(:cards, quiz.cards)}
  end

  defp _get_quiz_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    Repo.one!(query)
  end

  @impl true
  def handle_params(params, _url, socket) do
    quiz = socket.assigns[:quiz] || _get_quiz_or_404(params)

    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(
       quiz: quiz,
       page_title: "Card List",
       page_subtitle: quiz.name
     )}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, card: nil)
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, %{
      card: %Card{},
      modal_title: "New Card"
    })
  end

  # defp apply_action(socket, :edit, %{"card_id" => card_id}) do
  #   socket
  #   |> assign(:page_title, "Edit Card")
  #   |> assign(:card, Quizzes.get_card!(card_id))
  # end

  @impl true
  def handle_info({QuizGameWeb.Quizzes.CardLive.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  # @impl true
  # def handle_event("delete", %{"card_id" => card_id}, socket) do
  #   card = Quizzes.get_card!(card_id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
