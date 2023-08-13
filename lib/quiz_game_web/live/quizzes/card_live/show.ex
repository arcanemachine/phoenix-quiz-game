defmodule QuizGameWeb.Quizzes.CardLive.Show do
  use QuizGameWeb, :live_view

  alias QuizGame.Quizzes

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = Quizzes.get_quiz!(params["quiz_id"])

    {:ok, socket |> assign(:quiz, quiz)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:card, Quizzes.get_card!(id))}
  end

  defp page_title(:show), do: "Card Info"
  defp page_title(:edit), do: "Edit Card"
end
