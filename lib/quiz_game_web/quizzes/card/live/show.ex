defmodule QuizGameWeb.Quizzes.Card.Live.Show do
  @moduledoc false

  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Card

  defp _get_card_or_404(params) do
    query =
      from c in Card,
        where: c.quiz_id == ^params["quiz_id"] and c.id == ^params["card_id"],
        preload: [:quiz]

    QuizGame.Repo.one!(query)
  end

  @impl true
  def mount(params, _session, socket) do
    card = _get_card_or_404(params)

    {:ok, socket |> assign(card: card)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    card = socket.assigns[:card] || _get_card_or_404(params)

    {:noreply,
     socket
     |> assign(
       page_title: "Question Info",
       page_subtitle: card.quiz.name,
       card: card
     )}
  end

  @impl true
  def handle_info({QuizGameWeb.Quizzes.Card.Live.FormComponent, {:saved, card}}, socket) do
    # update the saved card after saving the form
    {:noreply, socket |> assign(card: card)}
  end

  @impl true
  def handle_event("delete_card", _params, socket) do
    # delete the card and redirect to the card list
    socket =
      case Quizzes.delete_card(socket.assigns.card) do
        {:ok, _} ->
          socket
          |> push_redirect(
            to: ~p"/quizzes/#{socket.assigns.card.quiz_id}/questions?delete-question-success=1",
            replace: true
          )

        {:error, _} ->
          socket
          |> push_redirect(
            to: ~p"/quizzes/#{socket.assigns.card.quiz_id}/questions?delete-question-error=1",
            replace: true
          )
      end

    {:noreply, socket}
  end

  # @impl true
  # def handle_event("delete", %{"card_id" => card_id}, socket) do
  #   card = Quizzes.get_card!(card_id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
