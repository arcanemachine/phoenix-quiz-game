defmodule QuizGame.Quizzes.Quiz do
  @moduledoc "The Quiz schema."
  use Ecto.Schema
  import Ecto.Changeset

  def name_length_max(), do: 64

  schema "quizzes" do
    field :name, :string
    # field :subject, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> validate_length(:name, max: name_length_max())

    # |> cast(attrs, [:name, :subject])
    # |> validate_required([:name, :subject])
  end
end
