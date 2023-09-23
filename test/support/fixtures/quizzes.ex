defmodule QuizGame.TestSupport.Fixtures.Quizzes do
  @moduledoc "Test helpers for creating entities via the `QuizGame.Quizzes` context."
  import QuizGame.TestSupport.Fixtures.Users
  alias QuizGame.Quizzes

  def unique_quiz_name, do: "quiz#{System.unique_integer()}"
  def unique_display_name, do: "quiz#{System.unique_integer()}"

  def quiz_fixture(attrs \\ %{}) do
    # maybe generate user
    user_id = attrs[:user_id] || user_fixture().id

    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        name: unique_quiz_name(),
        subject: :other
      })
      |> Quizzes.create_quiz(unsafe: true)

    quiz
  end

  def card_fixture(attrs \\ %{}) do
    # maybe generate quiz and user
    quiz_id = attrs[:quiz_id] || quiz_fixture().id

    # create card
    {:ok, card} =
      attrs
      |> Enum.into(%{
        quiz_id: quiz_id,
        format: :true_or_false,
        # image: nil,
        question: "some question",
        correct_answer: "true"
      })
      |> Quizzes.create_card(unsafe: true)

    card
  end

  def record_fixture(attrs \\ %{}) do
    # maybe generate quiz and user
    user_id = attrs[:user_id] || user_fixture().id
    quiz_id = attrs[:quiz_id] || quiz_fixture(user_id: user_id).id

    {:ok, record} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        quiz_id: quiz_id,
        display_name: "display_name#{System.unique_integer()}",
        card_count: 42,
        score: 42
      })
      |> QuizGame.Quizzes.create_record()

    record
  end
end
