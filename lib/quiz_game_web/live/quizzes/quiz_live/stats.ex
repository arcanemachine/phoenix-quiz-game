defmodule QuizGameWeb.Quizzes.QuizLive.Stats do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo
  alias QuizGameWeb.{Endpoint, Presence}

  @presence_topic "quiz_presence"

  @impl true
  def mount(params, _session, socket) do
    quiz = _get_quiz_or_404(params)

    # presence
    if connected?(socket), do: Endpoint.subscribe(@presence_topic)

    {:ok,
     assign(socket,
       page_title: "Quiz Live Stats",
       page_subtitle: quiz.name,
       connected: connected?(socket),
       quiz: quiz
     )
     |> _assign_presence_data()}

    # |> _assign_recently_completed_users(presence_data)}
  end

  defp _get_quiz_or_404(params) do
    Repo.one!(from q in Quiz, where: q.id == ^params["quiz_id"])
  end

  def _assign_presence_data(socket) do
    presence_data = Presence.list_data_for(@presence_topic, socket.assigns.quiz.id)

    if !connected?(socket) do
      assign(socket,
        presence_users_not_yet_started: [],
        presence_users_in_progress: [],
        presence_users_completed: []
      )
    else
      assign(socket,
        presence_users_not_yet_started:
          _get_presence_users_by_quiz_state(presence_data, :enter_display_name) ++
            _get_presence_users_by_quiz_state(presence_data, :before_start),
        presence_users_in_progress:
          _get_presence_users_by_quiz_state(presence_data, :in_progress),
        presence_users_completed: _get_presence_users_by_quiz_state(presence_data, :completed)
      )
    end
  end

  defp _get_presence_users_by_quiz_state(presence_data, quiz_state) do
    Enum.filter(presence_data, fn data -> data.quiz_state == quiz_state end)
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, socket |> _assign_presence_data()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <ul class="mt-12 list list-none [&>*]:mt-4">
      <li class="min-h-[10rem]">
        <span class="text-xl font-bold">
          Users preparing to take this quiz (<%= length(@presence_users_not_yet_started) %>)
        </span>
        <ul class="list">
          <%= if !@connected do %>
            <li class="italic">No users are preparing to take this quiz.</li>
          <% else %>
            <%= if Enum.empty?(@presence_users_not_yet_started) do %>
              <li class="italic">No users are preparing to take this quiz.</li>
            <% else %>
              <%= for data <- @presence_users_not_yet_started do %>
                <._user_detail data={data} current_user={@current_user} />
              <% end %>
            <% end %>
          <% end %>
        </ul>
      </li>
      <li class="min-h-[10rem]">
        <span class="text-xl font-bold">
          Users taking this quiz (<%= length(@presence_users_in_progress) %>)
        </span>
        <ul class="list">
          <%= if !@connected do %>
            <li class="italic">No users are taking this quiz.</li>
          <% else %>
            <%= if Enum.empty?(@presence_users_in_progress) do %>
              <li class="italic">No users are taking this quiz.</li>
            <% else %>
              <%= for data <- @presence_users_in_progress do %>
                <._user_detail data={data} current_user={@current_user} />
              <% end %>
            <% end %>
          <% end %>
        </ul>
      </li>
      <li class="min-h-[10rem]">
        <span class="text-xl font-bold">
          Users who have recently completed this quiz (<%= length(@presence_users_completed) %>)
        </span>
        <ul class="list">
          <%= if !@connected do %>
            <li class="italic">No users have completed this quiz.</li>
          <% else %>
            <%= if Enum.empty?(@presence_users_completed) do %>
              <li class="italic">No users have completed this quiz.</li>
            <% else %>
              <%= for data <- @presence_users_completed do %>
                <._user_detail data={data} current_user={@current_user} />
              <% end %>
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

  attr :data, :any, required: true
  attr :current_user, :any, required: true

  defp _user_detail(assigns) do
    ~H"""
    <li>
      <%= if @data.user do %>
        <%= @data.user.display_name %> (username: <%= @data.user.username %>)
        <%= if @data.user.id == @current_user.id do %>
          <b>(You)</b>
        <% end %>
      <% else %>
        <%= @data.display_name || raw("<i>No name yet</i>") %> (<i>unauthenticated</i>)
      <% end %>
    </li>
    """
  end
end
