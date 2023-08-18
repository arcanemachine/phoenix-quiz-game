defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
