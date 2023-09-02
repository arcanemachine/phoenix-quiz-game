defmodule QuizGame.Quizzes.Record do
  @moduledoc "The record schema."
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    # associations
    belongs_to :user, QuizGame.Users.User
    belongs_to :quiz, QuizGame.Quizzes.Quiz

    # data
    field :display_name, :string
    field :card_count, :integer
    field :correct_answer_count, :integer

    timestamps()
  end

  @fields [:user_id, :quiz_id, :display_name, :card_count, :correct_answer_count]

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:quiz_id)
  end
end
