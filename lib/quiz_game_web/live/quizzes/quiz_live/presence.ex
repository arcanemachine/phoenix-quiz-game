defmodule QuizGameWeb.Quizzes.QuizLive.Presence do
  use QuizGameWeb, :live_component
  alias QuizGameWeb.Presence

  @presence_topic "quiz_presence"

  # def mount(socket) do
  #   {:ok, socket}
  # end

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       quiz_users: Presence.list_users_for(@presence_topic, assigns.quiz_id)
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="mt-12">
      <div class="text-xl font-bold">Users taking this quiz:</div>
      <ul class="list">
        <%= if Enum.empty?(@quiz_users) do %>
          <li class="italic">There are no users currently taking this quiz.</li>
        <% else %>
          <%= for user <- @quiz_users do %>
            <li><%= user.username %></li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end
end
