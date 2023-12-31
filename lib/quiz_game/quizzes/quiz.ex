defmodule QuizGame.Quizzes.Quiz do
  @moduledoc "The quiz schema."
  use Ecto.Schema
  import Ecto.Changeset
  alias QuizGameWeb.Support, as: S

  def math_random_question_count_min(), do: 0
  def math_random_question_count_max(), do: 500
  def math_random_question_value_min(), do: -999
  def math_random_question_value_max(), do: 999

  schema "quizzes" do
    # associations
    belongs_to :user, QuizGame.Users.User
    has_many :cards, QuizGame.Quizzes.Card
    has_many :records, QuizGame.Quizzes.Record

    # data
    field :name, :string
    field :subject, Ecto.Enum, values: [:language, :math, :science, :social_studies, :other]

    field :math_random_question_count, :integer

    field :math_random_question_operations, {:array, Ecto.Enum},
      values: [:add, :subtract, :multiply, :divide]

    field :math_random_question_value_min, :integer
    field :math_random_question_value_max, :integer
    field :math_random_question_left_constant, :integer

    timestamps()
  end

  def name_length_max(), do: 32

  def math_random_question_operations_readable(%__MODULE__{} = quiz) do
    quiz.math_random_question_operations
    |> Enum.map_join(", ", fn x -> Atom.to_string(x) |> String.capitalize() end)
  end

  @unsafe_fields_required [:user_id]
  @safe_fields_required [:name, :subject]
  @safe_fields_optional [
    :math_random_question_count,
    :math_random_question_operations,
    :math_random_question_value_min,
    :math_random_question_value_max
  ]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(%__MODULE__{} = quiz, attrs \\ %{}) do
    quiz
    |> cast(attrs, @safe_fields_required ++ @safe_fields_optional)
    |> cast_quiz()
    |> validate_required(@safe_fields_required)
    |> validate_length(:name, max: name_length_max())
    |> validate_quiz()
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(%__MODULE__{} = quiz, attrs \\ %{}) do
    quiz
    |> changeset(attrs)
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> foreign_key_constraint(:user_id)
  end

  @doc "Perform context-dependent validations on a quiz' changeset (e.g. for different subjects)."
  @spec cast_quiz(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def cast_quiz(changeset) do
    subject = S.Changeset.get_value_from_changes_or_data(changeset, :subject)

    math_random_question_count =
      S.Changeset.get_value_from_changes_or_data(changeset, :math_random_question_count)

    # if quiz does not have random math questions, then clear the fields related to random
    # math questions
    if subject != :math || Enum.member?([nil, 0], math_random_question_count) do
      changeset
      |> change(
        math_random_question_count: nil,
        math_random_question_operations: nil,
        math_random_question_value_min: nil,
        math_random_question_value_max: nil
      )
    else
      changeset
    end
  end

  @spec validate_quiz(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_quiz(changeset) do
    # subject
    if S.Changeset.get_value_from_changes_or_data(changeset, :subject) == :math,
      do: validate_subject_math(changeset),
      else: changeset
  end

  @doc "Validations for quizzes whose subject is 'math'."
  @spec validate_subject_math(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_subject_math(changeset) do
    if !!S.Changeset.get_value_from_changes_or_data(changeset, :math_random_question_count) do
      ## Quiz has randomly-generated math questions. Validate data related to them.

      changeset
      # for data related to math questions, insert all changed and unchanged data into the
      # changeset so that the validation functions will validate the existing data, not just
      # the changed data
      |> S.Changeset.ensure_data_in_changes([
        :math_random_question_count,
        :math_random_question_operations,
        :math_random_question_value_min,
        :math_random_question_value_max
      ])

      # must have at least one math operation selected
      |> validate_length(:math_random_question_operations, min: 1)

      # random question count must be in the allowed numeric range
      |> validate_number(:math_random_question_count,
        greater_than_or_equal_to: math_random_question_count_min(),
        less_than: math_random_question_count_max()
      )

      # minimum value must be greater than the allowed minimum value
      |> validate_number(:math_random_question_value_min,
        greater_than_or_equal_to: math_random_question_value_min()
      )

      # chosen maximum value must be greater than the chosen minimum value
      |> validate_number(:math_random_question_value_max,
        greater_than:
          S.Changeset.get_value_from_changes_or_data(changeset, :math_random_question_value_min),
        message: "must be greater than the minimum random value"
      )

      # chosen value must be less than the allowed maximum value
      |> validate_number(:math_random_question_value_max,
        less_than_or_equal_to: math_random_question_value_max()
      )
    else
      changeset
    end
  end
end
