defmodule QuizGameWeb.Quizzes.Quiz.HTML do
  @moduledoc false
  use QuizGameWeb, :html

  embed_templates "html/*"

  @doc "Renders a quiz form."
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def quiz_form(assigns)
end
