defmodule QuizGameWeb.Quizzes.CardLive.Show do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.{Quizzes, Repo}
  alias QuizGame.Quizzes.Card

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    # get card
    query =
      from c in Card,
        where: c.quiz_id == ^params["quiz_id"] and c.id == ^params["card_id"],
        preload: [:quiz]

    card = Repo.one(query)

    {:noreply,
     assign(socket, %{
       page_title: "Card Info",
       page_subtitle: card.quiz.name,
       card: card
     })}
  end

  @impl Phoenix.LiveView
  def handle_info({QuizGameWeb.Quizzes.CardLive.FormComponent, {:saved, card}}, socket) do
    # update the saved card after saving the form
    {:noreply, assign(socket, :card, card)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", _params, socket) do
    # delete the card and redirect to the card list
    socket =
      case Quizzes.delete_card(socket.assigns.card) do
        {:ok, _} ->
          socket
          |> put_flash(:success, "Card deleted successfully")
          |> push_navigate(
            to: route(:quizzes_cards, :index, quiz_id: socket.assigns.card.quiz_id),
            replace: true
          )

        {:error, _} ->
          socket
          |> put_flash(:error, "Could not delete the card. Has it already been deleted?")
          |> push_navigate(
            to: route(:quizzes_cards, :index, quiz_id: socket.assigns.card.quiz_id),
            replace: true
          )
      end

    {:noreply, socket}
  end

  # @impl Phoenix.LiveView
  # def handle_event("delete", %{"card_id" => card_id}, socket) do
  #   card = Quizzes.get_card!(card_id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
