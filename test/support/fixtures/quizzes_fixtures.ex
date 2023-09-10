defmodule QuizGame.TestSupport.QuizzesFixtures do
  @moduledoc "Test helpers for creating entities via the `QuizGame.Quizzes` context."
  import QuizGame.TestSupport.UsersFixtures
  alias QuizGame.Quizzes

  @doc "Generate a quiz."
  def quiz_fixture(attrs \\ %{}) do
    # maybe generate user
    user_id = attrs[:user_id] || user_fixture().id

    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        name: "some name",
        subject: :other
      })
      |> Quizzes.create_quiz(unsafe: true)

    quiz
  end

  @doc "Generate a card."
  def card_fixture(attrs \\ %{}) do
    # maybe generate quiz and user
    user_id = attrs[:user_id] || user_fixture().id
    quiz_id = attrs[:quiz_id] || quiz_fixture(user_id: user_id).id

    # create card
    {:ok, card} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        quiz_id: quiz_id,
        format: :text_entry,
        # image: nil,
        question: "some question",
        correct_answer: "some correct answer"
      })
      |> Quizzes.create_card(unsafe: true)

    card
  end

  @doc "Generate a quiz record."
  def record_fixture(attrs \\ %{}) do
    {:ok, record} =
      attrs
      |> Enum.into(%{
        date: ~U[2023-08-31 02:31:00Z],
        card_count: 42,
        score: 42
      })
      |> QuizGame.Quizzes.create_record()

    record
  end
end
