defmodule QuizGameWeb.QuizHTML do
  use QuizGameWeb, :html

  embed_templates "quiz_html/*"

  @doc """
  Renders a quiz form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def quiz_form(assigns)
end
