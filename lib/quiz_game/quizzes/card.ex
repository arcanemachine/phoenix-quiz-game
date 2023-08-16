defmodule QuizGame.Quizzes.Card do
  @moduledoc "The Card schema."
  use Ecto.Schema
  import Ecto.Changeset

  @doc "Creates :format options usable in a <.input type='select'> component."
  def format_options() do
    Ecto.Enum.values(__MODULE__, :format)
    |> Enum.map(fn item ->
      {item |> QuizGameWeb.Support.Atom.to_human_friendly_string(), item}
    end)
  end

  schema "cards" do
    # associations
    belongs_to :quiz, QuizGame.Quizzes.Quiz

    # data
    field :question, :string
    field :format, Ecto.Enum,
      values: [:multiple_choice, :true_or_false, :text_entry, :number_entry],
      default: :multiple_choice

    field :image, :string

    field :choice_1, :string
    field :choice_2, :string
    field :choice_3, :string
    field :choice_4, :string

    field :answer, :string

    # # attributes
    # add :shuffle_questions, :boolean, null: false
    # add :shuffle_answers, :boolean, null: false

    # # computed
    # field :index, :integer

    timestamps()
  end

  @unsafe_fields_required [:quiz_id]
  @safe_fields_required [:format, :question, :answer]
  @safe_fields_optional [:image, :choice_1, :choice_2, :choice_3, :choice_4]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@safe_fields_required)
    |> validate_choices()
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> foreign_key_constraint(:quiz_id)
  end

  def validate_choices(changeset) do
    if changeset.data.format != :multiple_choice do
      # ignore this field if we're not in a multiple choice question
      # TO-DO: convert all choices to empty string values?
      true
    else
      changeset |> validate_required([:choice_1, :choice_2, :choice_3, :choice_4])
    end
  end
end
