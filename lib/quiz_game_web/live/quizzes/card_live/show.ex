defmodule QuizGameWeb.Quizzes.CardLive.Show do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.{Quizzes, Repo}
  alias QuizGame.Quizzes.Card

  def get_card(params) do
    query = from c in Card, where: c.quiz_id == ^params["quiz_id"] and c.id == ^params["id"]
    card = Repo.one(query) |> Repo.preload(:quiz)
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    # quiz = Quizzes.get_quiz!(params["quiz_id"])
    card = get_card(params)

    {:ok, assign(socket, :card, card)}
    # {:ok, assign(socket)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id} = params, _url, socket) do
    # card = Quizzes.get_card!(id) |> Repo.preload(:quiz)
    card = socket.assigns[:card] || get_card(params)

    {:noreply,
     assign(socket, %{
       page_title: "Card Info",
       page_subtitle: card.quiz.name,
       card: card
       # card: Quizzes.get_card!(id)
     })}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", _params, socket) do
    # delete the card and redirect to the card list
    case Quizzes.delete(socket.assigns.card) do
      {:ok, _} ->
        socket
        |> put_flash(:success, "Card deleted successfully")
        |> push_patch(to: route(:quizzes_cards, :index, quiz_id: socket.assigns.quiz.id))

      {:error, _} ->
        socket
        |> put_flash(:error, "Could not delete the card. Has it already been deleted?")
        |> push_patch(to: route(:quizzes_cards, :index, quiz_id: socket.assigns.quiz.id))
    end
  end

  # @impl Phoenix.LiveView
  # def handle_event("delete", %{"id" => id}, socket) do
  #   card = Quizzes.get_card!(id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
