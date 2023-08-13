defmodule QuizGameWeb.Quizzes.CardLive.Index do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Repo
  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.{Card, Quiz}

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = Quizzes.get_quiz!(params["quiz_id"]) |> Repo.preload([:cards])

    {:ok, socket |> assign(:quiz, quiz) |> stream(:cards, quiz.cards)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(%{
       page_title: "Card List",
       page_subtitle: socket.assigns.quiz.name
     })}
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

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Card")
  #   |> assign(:card, Quizzes.get_card!(id))
  # end

  @impl Phoenix.LiveView
  def handle_info({QuizGameWeb.Quizzes.CardLive.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  # @impl Phoenix.LiveView
  # def handle_event("delete", %{"id" => id}, socket) do
  #   card = Quizzes.get_card!(id)
  #   {:ok, _} = Quizzes.delete_card(card)

  #   {:noreply, stream_delete(socket, :cards, card)}
  # end
end
