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

  @unsafe_fields_required [:user_id]
  @safe_fields_required [:name]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(quiz, attrs \\ %{})

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name])
    |> cast(attrs, @safe_fields_required)
    |> validate_required(@safe_fields_required)
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(quiz, attrs \\ %{})

  def unsafe_changeset(quiz, attrs) do
    quiz
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> validate_length(:name, max: name_length_max())
  end

  @doc "Returns a changeset with all unsafe parameters removed."
  def changeset_make_safe(%Ecto.Changeset{} = unsafe_changeset) do
    changeset(%__MODULE__{}, unsafe_changeset.params)
  end
end
