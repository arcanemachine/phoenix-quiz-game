defmodule QuizGame.Quizzes.QuizRecord do
  @moduledoc "The quiz_record schema."
  use Ecto.Schema
  import Ecto.Changeset

  schema "quiz_records" do
    # associations
    belongs_to :user, QuizGame.Users.User
    belongs_to :quiz, QuizGame.Quizzes.Quiz

    # data
    field :card_count, :integer
    field :correct_answer_count, :integer

    timestamps()
  end

  @fields [:user_id, :quiz_id, :card_count, :correct_answer_count]

  @doc false
  def changeset(quiz_record, attrs) do
    quiz_record
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:quiz_id)
  end
end
