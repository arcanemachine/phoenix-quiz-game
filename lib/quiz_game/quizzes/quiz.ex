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
    |> validate_number(:math_random_question_count,
      greater_than_or_equal_to: math_random_question_count_min(),
      less_than_or_equal_to: math_random_question_count_max()
    )
    |> validate_subject()
    |> foreign_key_constraint(:user_id)
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(quiz, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> validate_length(:name, max: name_length_max())
    |> validate_number(:math_random_question_count,
      greater_than_or_equal_to: math_random_question_count_min(),
      less_than_or_equal_to: math_random_question_count_max()
    )
    |> validate_subject()
    |> foreign_key_constraint(:user_id)
  end

  @spec changeset_field_is_or_will_be(Ecto.Changeset.t(), atom(), any()) :: boolean()
  def changeset_field_is_or_will_be(changeset, field, value) do
    if Map.get(changeset.changes, field) == value do
      # matching value in changes
      true
    else
      # existing value matches and other value not in changes
      if get_in(changeset.data, [Access.key(field)]) == value && !Map.has_key?(changeset, field) do
        true
      else
        false
      end
    end
  end

  # @spec changeset_get_changed_or_existing_value(Ecto.Changeset.t(), atom(), any()) :: any()
  # def changeset_get_changed_or_existing_value(changeset, field, default) do
  #   :fixme
  # end

  @spec validate_subject(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_subject(changeset) do
    if changeset |> changeset_field_is_or_will_be(:subject, :math) do
      changeset |> validate_subject_math()
    else
      changeset_remove_math_random_question_data(changeset)
    end
  end

  @doc "Validations for quizzes whose subject is 'math'."
  @spec validate_subject_math(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_subject_math(changeset) do
    case Map.get(changeset.changes, :math_random_question_count) do
      0 ->
        changeset_remove_math_random_question_data(changeset)

      _ ->
        changeset

        # |> validate_number(:math_random_question_count_max, greater_than: changeset_get_changed_or_existing_value(changeset, :math_random_question_value_min))
    end
  end

  @spec changeset_remove_math_random_question_data(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def changeset_remove_math_random_question_data(changeset) do
    changeset
    |> change(
      math_random_question_count: 0,
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
