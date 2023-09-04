defmodule QuizGameWeb.Quizzes.QuizLive.Stats do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo
  alias QuizGameWeb.{Endpoint, Presence}

  @presence_topic "quiz_presence"

  defp _get_quiz_or_404(params) do
    Repo.one!(from q in Quiz, where: q.id == ^params["quiz_id"])
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@presence_topic)
    end

    quiz = _get_quiz_or_404(params)

    {:ok,
     socket
     |> assign(
       page_title: "Quiz Live Stats",
       page_subtitle: quiz.name,
       quiz: quiz,
       users: Presence.list_users_for(@presence_topic, quiz.id)
     )}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply,
     socket |> assign(users: Presence.list_users_for(@presence_topic, socket.assigns.quiz.id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-12">
      <div class="text-xl font-bold">Users taking this quiz:</div>
      <ul class="list">
        <%= if Enum.empty?(@users) do %>
          <li class="italic">There are no users currently taking this quiz.</li>
        <% else %>
          <%= for user <- @users do %>
            <li><%= user.username %></li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end
end
