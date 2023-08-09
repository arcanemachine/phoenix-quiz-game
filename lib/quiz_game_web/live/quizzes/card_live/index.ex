defmodule QuizGameWeb.Quizzes.CardLive.Index do
  use QuizGameWeb, :live_view

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Card

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :cards, Quizzes.list_cards())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Card")
    |> assign(:card, Quizzes.get_card!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Card")
    |> assign(:card, %Card{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cards")
    |> assign(:card, nil)
  end

  @impl true
  def handle_info({QuizGameWeb.Quizzes.CardLive.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    card = Quizzes.get_card!(id)
    {:ok, _} = Quizzes.delete_card(card)

    {:noreply, stream_delete(socket, :cards, card)}
  end
end
