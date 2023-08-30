defmodule QuizGameWeb.Quizzes.UserActivityLive do
  use QuizGameWeb, :live_component
  alias QuizGameWeb.Presence

  def update(_assigns, socket) do
    {:ok, socket |> assign_user_activity()}
  end

  def assign_quiz_user_activity(socket) do
    assign(socket, :user_activity, Presence.list_users())
  end
end
