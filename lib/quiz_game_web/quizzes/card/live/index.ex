defmodule QuizGameWeb.Quizzes.Card.Live.Index do
  @moduledoc false
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.{Card, Quiz}
  alias QuizGame.Repo

  @impl true
  def mount(params, _session, socket) do
    quiz = _get_quiz_or_404(params)

    {:ok, socket |> assign(quiz: quiz) |> stream(:cards, quiz.cards)}
  end

  defp _get_quiz_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    Repo.one!(query)
  end

  @impl true
  def handle_params(params, url, socket) do
    quiz = socket.assigns[:quiz] || _get_quiz_or_404(params)

    # if card deletion params present, show flash message and redirect to current path without
    # query string
    socket =
      cond do
        params["delete-question-success"] == "1" ->
          socket
          |> put_flash(:success, "Question deleted successfully")
          |> redirect(to: URI.parse(url).path)

        params["delete-question-error"] == "1" ->
          socket
          |> put_flash(:success, "Could not delete the question. Has it already been deleted?")
          |> redirect(to: URI.parse(url).path)

        true ->
          socket
          |> apply_action(socket.assigns.live_action, params)
          |> assign(
            quiz: quiz,
            page_title: "Question List",
            page_subtitle: quiz.name
          )
      end

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, card: nil)
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, %{
      card: %Card{},
      modal_title: "New Question"
    })
  end

  # defp apply_action(socket, :edit, %{"card_id" => card_id}) do
  #   socket
  #   |> assign(:page_title, "Edit Card")
  #   |> assign(:card, Quizzes.get_card!(card_id))
  # end

  @impl true
  def handle_info({QuizGameWeb.Quizzes.Card.Live.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  # @impl true
  # def handle_event("delete", %{"card_id" => card_id}, socket) do
  #   card = Quizzes.get_card!(card_id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
