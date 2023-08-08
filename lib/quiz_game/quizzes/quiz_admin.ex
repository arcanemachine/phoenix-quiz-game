defmodule QuizGame.Quizzes.QuizAdmin do
  @moduledoc "The Kaffy admin configuration for the Quiz schema."

  def singular_name(_), do: "Quiz"
  def plural_name(_), do: "Quizzes"

  def index(_) do
    [
      name: nil,
      id: nil,
      user_id: %{name: "Created by"}
    ]
  end

  def form_fields(_) do
    [
      name: %{create: :hidden}
    ]
  end
end
