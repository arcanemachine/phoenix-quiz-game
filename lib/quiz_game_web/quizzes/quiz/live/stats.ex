defmodule QuizGameWeb.Quizzes.Quiz.Live.Stats do
  @moduledoc false

  use QuizGameWeb, :live_view

  import Ecto.Query
  import QuizGameWeb.Quizzes.Components

  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo
  alias QuizGameWeb.{Endpoint, Presence}
  alias QuizGameWeb.Quizzes.Quiz.Live.Take

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
  end

  defp _get_quiz_or_404(params) do
    Repo.one!(from q in Quiz, where: q.id == ^params["quiz_id"])
  end

  def _assign_presence_data(socket) do
    presence_data =
      Presence.list_data_for(@presence_topic, socket.assigns.quiz.id)
      |> Enum.sort(&(&1.display_name < &2.display_name))

    if !connected?(socket) do
      socket
      |> assign(
        presence_users_not_yet_started: [],
        presence_users_in_progress: [],
        presence_users_completed: []
      )
    else
      socket
      |> assign(
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
    <div class="text-center">
      <div class="min-h-[10rem]">
        <div class="text-xl font-bold">
          Users in the quiz lobby (<%= length(@presence_users_not_yet_started) %>)
        </div>
        <div class="mt-1 text-center">
          <%= if !@connected || Enum.empty?(@presence_users_not_yet_started) do %>
            <div class="italic">No users are preparing to take this quiz.</div>
          <% else %>
            <div class="flex flex-wrap" data-test-id="users-not-yet-started">
              <%= for data <- @presence_users_not_yet_started do %>
                <._user_detail_card data={data} />
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      <div class="min-h-[10rem]">
        <div class="mt-12 text-xl font-bold">
          Users taking this quiz (<%= length(@presence_users_in_progress) %>)
        </div>
        <div class="mt-1 text-center">
          <%= if !@connected || Enum.empty?(@presence_users_in_progress) do %>
            <div class="italic">No users are taking this quiz.</div>
          <% else %>
            <div class="flex flex-wrap" data-test-id="users-in-progress">
              <%= for data <- @presence_users_in_progress do %>
                <._user_detail_card data={data} />
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      <div class="min-h-[10rem]">
        <div class="mt-12 text-xl font-bold">
          Users recently completed (<%= length(@presence_users_completed) %>)
        </div>
        <div class="mt-1 text-center">
          <%= if !@connected || Enum.empty?(@presence_users_completed) do %>
            <div class="italic">No users have recently completed this quiz.</div>
          <% else %>
            <div class="flex flex-wrap gap-4" data-test-id="users-completed">
              <%= for data <- @presence_users_completed do %>
                <._user_detail_card data={data} />
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <.action_links class="mt-12">
      <.action_links_item kind="back">
        <.link href={~p"/quizzes/#{@quiz.id}"}>
          Return to quiz
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end

  attr :data, :any, required: true

  defp _user_detail_card(assigns) do
    ~H"""
    <div
      class="mt-2 mx-auto px-2 card w-full max-w-md bg-secondary/10 border border-secondary/5
             shadow-lg shadow-secondary/10"
      x-title="user-detail-card"
      x-data="collapseIn"
    >
      <div class="card-body">
        <%!-- name --%>
        <div>
          <%= if @data.user do %>
            <%= @data.user.display_name %> (username: <%= @data.user.username %>)
          <% else %>
            <%= @data.display_name || raw("<i>No name yet</i>") %> (<i>unauthenticated</i>)
          <% end %>
        </div>

        <%!-- quiz progress and score info --%>
        <%= if Enum.member?([:in_progress, :completed], @data.quiz_state) do %>
          <div class="mt-1">
            <.quiz_progress
              percent_completed={
                Take.get_percent_completed_as_integer(@data.current_card_index, @data.quiz_length)
              }
              percent_correct={
                Take.get_total_percent_correct_as_integer(@data.score, @data.quiz_length)
              }
            />
          </div>

          <div class="mt-1" data-test-id="quiz-stats">
            <span :if={@data.current_card_index > 0}>
              <b>
                <%= Take.get_score_percent_as_integer(@data.score, @data.current_card_index) %>%
              </b>
              -
            </span>
            <%= @data.score %> / <%= @data.current_card_index %> correct
            <%= if @data.quiz_state == :in_progress do %>
              (<%= @data.quiz_length - @data.current_card_index %> remaining)
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
