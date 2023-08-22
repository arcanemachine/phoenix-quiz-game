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
    field :subject, Ecto.Enum, values: [:math, :language, :science, :social_studies, :other]

    # field :math_operations, Ecto.Enum, values: [:add, :subtract, :multiply, :divide]
    # field :math_question_count, :integer
    # field :math_value_min, :integer
    # field :math_value_max, :integer

    timestamps()
  end

  @unsafe_fields_required [:user_id]
  @safe_fields_required [:name, :subject]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(quiz \\ %__MODULE__{}, attrs \\ %{})

  def changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> cast(attrs, @safe_fields_required)
    |> validate_required(@safe_fields_required)
    |> foreign_key_constraint(:user_id)
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(quiz, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = quiz, attrs) do
    quiz
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> validate_length(:name, max: name_length_max())
  end

  # @doc "Returns a changeset with all unsafe parameters removed."
  # def changeset_make_safe(%Ecto.Changeset{} = unsafe_changeset) do
  #   changeset(%__MODULE__{}, unsafe_changeset.params)
  # end
end
