defmodule QuizGameWeb.QuizzesRouter do
  @moduledoc """
  Routes for the 'quizzes' context.
  """

  def browser do
    quote do
      # login required
      scope "/quizzes", QuizGameWeb do
        pipe_through([:browser, :require_authenticated_user])

        resources "/", QuizController, param: "id"
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use QuizzesRouter, :api
      use QuizzesRouter, :browser
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
