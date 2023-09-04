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
    quiz = _get_quiz_or_404(params)

    if connected?(socket), do: Endpoint.subscribe(@presence_topic)

    presence_data = Presence.list_data_for(@presence_topic, quiz.id)

    {:ok,
     socket
     |> assign(
       page_title: "Quiz Live Stats",
       page_subtitle: quiz.name,
       connected: connected?(socket),
       quiz: quiz,
     )
     |> _assign_presence_data(presence_data)}
     # |> _assign_recently_completed_users(presence_data)}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    presence_data = Presence.list_data_for(@presence_topic, socket.assigns.quiz.id)
    {:noreply,
     socket
     |> _assign_presence_data(presence_data)}
  end

  def _assign_presence_data(socket, presence_data) do
    socket |> assign(
       presence_users_before_start: _get_presence_users_by_quiz_status(presence_data, :before_start),
       presence_users_in_progress: _get_presence_users_by_quiz_status(presence_data, :in_progress)
    )
  end

  defp _get_presence_users_by_quiz_status(presence_data, quiz_status) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <ul class="mt-12 list">
      <li>
        <span class="text-xl font-bold">
          Users taking this quiz (<%= length(@presence_users_in_progress) %>)
        </span>

        <ul class="list">
          <%= if @connected && Enum.empty?(@presence_users_in_progress) do %>
            <li class="italic">No users are taking this quiz.</li>
          <% else %>
            <%= for data <- @presence_users_before_start do %>
              <li :if={Enum.member?([:before_start, :enter_display_name], data.quiz_state)}>
                <%= if data.user do %>
                  <%= data.user.display_name %> (username: <i><%= data.user.username %></i>)
                  <%= if data.user.id == @current_user.id do %>
                    <b>(You)</b>
                  <% end %>
                <% else %>
                  <%= data.display_name || raw("No name yet") %> <i>(Unauthenticated)</i>
                <% end %>
              </li>
            <% end %>
          <% end %>
        </ul>
      </li>
    </ul>

    <.action_links class="mt-12">
      <.action_links_item kind="back">
        <.link href={route(:quizzes, :show, quiz_id: @quiz.id)}>
          Return to quiz
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end
end
