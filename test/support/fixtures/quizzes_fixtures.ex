defmodule QuizGame.TestSupport.QuizzesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the `QuizGame.Quizzes` context.
  """

  alias QuizGame.Quizzes

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Quizzes.create_quiz()

    quiz
  end

  @doc """
  Generate a card.
  """
  def card_fixture(attrs \\ %{}) do
    # create card
    {:ok, card} =
      attrs
      |> Enum.into(%{
        format: :multiple_choice,
        image: "some image",
        question: "some question",
        answers: ["option1", "option2"]
      })
      |> Quizzes.create_card()

    card
  end
end
