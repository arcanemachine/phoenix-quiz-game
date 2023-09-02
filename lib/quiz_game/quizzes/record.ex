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
    field :score, :integer

    timestamps()
  end

  @required_fields [:quiz_id, :display_name, :card_count, :score]
  @optional_fields [:user_id]

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:quiz_id)
  end
end
