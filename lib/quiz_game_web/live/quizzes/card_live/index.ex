defmodule QuizGameWeb.Quizzes.CardLive.Index do
  use QuizGameWeb, :live_view

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Card

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = Quizzes.get_quiz!(params["quiz_id"])

    {:ok, socket |> assign(:quiz, quiz) |> stream(:cards, Quizzes.list_cards())}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(%{
      page_title: "Card List",
      page_subtitle: socket.assigns.quiz.name,
      card: nil
    })
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Card")
    |> assign(:card, %Card{})
  end

  defp apply_action(socket, :edit, %{"quiz_id" => id, "id" => id}) do
    socket
    |> assign(:page_title, "Edit Card")
    |> assign(:card, Quizzes.get_card!(id))
  end

  @impl Phoenix.LiveView
  def handle_info({QuizGameWeb.Quizzes.CardLive.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    card = Quizzes.get_card!(id)
    {:ok, _} = Quizzes.delete_card(card)

    {:noreply, stream_delete(socket, :cards, card)}
  end
end
