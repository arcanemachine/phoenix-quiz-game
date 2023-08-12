defmodule QuizGame.Quizzes.Quiz do
  @moduledoc "The Quiz schema."
  use Ecto.Schema
  import Ecto.Changeset

  def name_length_max(), do: 64

  schema "quizzes" do
    # associations
    belongs_to :user, QuizGame.Users.User
    has_many :cards, QuizGame.Quizzes.Card

    # data
    field :name, :string

    timestamps()
  end

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset_safe(quiz, attrs \\ %{}) do
    quiz
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: name_length_max())
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def changeset_unsafe(quiz, attrs \\ %{}) do
    quiz
    |> cast(attrs, [:user_id, :name])
    |> validate_required([:user_id, :name])
    |> validate_length(:name, max: name_length_max())
  end
end
