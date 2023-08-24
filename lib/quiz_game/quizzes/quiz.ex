defmodule QuizGame.Quizzes.Quiz do
  @moduledoc "The Quiz schema."
  use Ecto.Schema
  import Ecto.Changeset

  schema "quizzes" do
    # associations
    belongs_to :user, QuizGame.Users.User
    has_many :cards, QuizGame.Quizzes.Card

    # data
    field :name, :string
    field :subject, Ecto.Enum, values: [:math, :language, :science, :social_studies, :other]

    field :math_random_question_count, :integer, default: 0

    field :math_random_question_operations, {:array, Ecto.Enum},
      values: [:add, :subtract, :multiply, :divide]

    field :math_random_question_value_min, :integer
    field :math_random_question_value_max, :integer

    timestamps()
  end

  def name_length_max(), do: 64

  def math_random_question_operations_readable(%__MODULE__{} = quiz) do
    quiz.math_random_question_operations
    |> Enum.map_join(", ", fn o -> Atom.to_string(o) |> String.capitalize() end)
  end

  def math_random_question_count_min(), do: 0
  def math_random_question_count_max(), do: 500

  @unsafe_fields_required [:user_id]
  @safe_fields_required [:name, :subject]
  @safe_fields_optional [
    :math_random_question_count,
    :math_random_question_operations,
    :math_random_question_value_min,
    :math_random_question_value_max
  ]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(quiz \\ %__MODULE__{}, attrs \\ %{})

  def changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> cast(attrs, @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@safe_fields_required)
    |> foreign_key_constraint(:user_id)
    # |> validate_math_quiz()
    # |> validate_non_math_quiz()
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(quiz, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> validate_length(:name, max: name_length_max())
    |> foreign_key_constraint(:user_id)
    # |> validate_math_quiz()
    # |> validate_non_math_quiz()
  end

  # @doc "Returns a changeset with all unsafe parameters removed."
  # def changeset_make_safe(%Ecto.Changeset{} = unsafe_changeset) do
  #   changeset(%__MODULE__{}, unsafe_changeset.params)
  # end
end
