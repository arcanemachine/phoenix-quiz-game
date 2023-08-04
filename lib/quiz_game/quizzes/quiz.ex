defmodule QuizGame.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quizzes" do
    field :name, :string
    # field :subject, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name])
    |> validate_required([:name])

    # |> cast(attrs, [:name, :subject])
    # |> validate_required([:name, :subject])
  end
end
