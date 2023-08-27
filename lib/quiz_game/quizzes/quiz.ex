defmodule QuizGame.Quizzes.Quiz do
  @moduledoc "The Quiz schema."

  use Ecto.Schema

  import Ecto.Changeset
  alias QuizGameWeb.Support, as: S

  schema "quizzes" do
    # associations
    belongs_to :user, QuizGame.Users.User
    has_many :cards, QuizGame.Quizzes.Card

    # data
    field :name, :string
    field :subject, Ecto.Enum, values: [:math, :language, :science, :social_studies, :other]

    field :math_random_question_count, :integer

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

  def math_random_question_value_min(), do: -999_999
  def math_random_question_value_max(), do: 999_999

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
    |> validate_length(:name, max: name_length_max())
    |> validate_subject()
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(quiz, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> changeset(attrs)
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> foreign_key_constraint(:user_id)
  end

  @spec validate_subject(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_subject(changeset) do
    if S.Changeset.field_will_have_value?(changeset, :subject, :math),
      do: changeset |> validate_subject_math(),
      else: changeset_remove_math_random_question_data(changeset)
  end

  @doc "Validations for quizzes whose subject is 'math'."
  @spec validate_subject_math(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_subject_math(changeset) do
    if S.Changeset.get_changed_or_existing_value(changeset, :math_random_question_count) > 0 do
      # quiz has randomly-generated questions. validate data related to them
      changeset
      |> validate_required([
        :math_random_question_count,
        :math_random_question_operations,
        :math_random_question_value_min,
        :math_random_question_value_max
      ])

      # 'operations' field must have one or more operatins
      |> validate_length(:math_random_question_operations, min: 1)

      # random question count must be in the allowable range
      |> validate_number(:math_random_question_count,
        greater_than_or_equal_to: math_random_question_count_min(),
        less_than_or_equal_to: math_random_question_count_max()
      )

      # minimum random value must be above the allowable minimum value
      |> validate_number(:math_random_question_value_min,
        greater_than_or_equal_to: math_random_question_value_min()
      )

      # maximum random value must be greater than the minimum value
      |> validate_number(:math_random_question_value_max,
        greater_than:
          S.Changeset.get_changed_or_existing_value(changeset, :math_random_question_value_min),
        message: "must be greater than the minimum random value"
      )

      # maximum random value must be less than the allowable maximum value
      |> validate_number(:math_random_question_value_max,
        less_than_or_equal_to: math_random_question_value_max()
      )
    else
      # quiz does not have randomly-generated questions. clear data related to them
      changeset_remove_math_random_question_data(changeset)
    end
  end

  @spec changeset_remove_math_random_question_data(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def changeset_remove_math_random_question_data(changeset) do
    changeset
    |> change(
      math_random_question_count: nil,
      math_random_question_operations: nil,
      math_random_question_value_min: nil,
      math_random_question_value_max: nil
    )
  end

  # @doc "Returns a changeset with all unsafe parameters removed."
  # def changeset_make_safe(%Ecto.Changeset{} = unsafe_changeset) do
  #   changeset(%__MODULE__{}, unsafe_changeset.params)
  # end
end
