defmodule QuizGame.TestSupport.QuizzesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the `QuizGame.Quizzes` context.
  """

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> QuizGame.Quizzes.create_quiz()

    quiz
  end
end
