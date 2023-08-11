defmodule QuizGameWeb.Quizzes.CardLive.Show do
  use QuizGameWeb, :live_view

  alias QuizGame.Quizzes

  @impl true
  def mount(params, _session, socket) do
    quiz = Quizzes.get_quiz!(params["quiz_id"])

    {:ok, socket |> assign(:quiz, quiz)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:card, Quizzes.get_card!(id))}
  end

  defp page_title(:show), do: "Show Card"
  defp page_title(:edit), do: "Edit Card"
end
