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
      values: [:multiple_choice, :true_or_false, :text_entry, :number_entry]

    # field :image, :string

    field :choice_1, :string
    field :choice_2, :string
    field :choice_3, :string
    field :choice_4, :string

    field :correct_answer, :string

    # # attributes
    # add :shuffle_questions, :boolean, null: false
    # add :shuffle_answers, :boolean, null: false

    # # computed
    # field :index, :integer

    timestamps()
  end

  @unsafe_fields_required [:quiz_id]
  @safe_fields_required [:format, :question, :correct_answer]
  @safe_fields_optional [:choice_1, :choice_2, :choice_3, :choice_4]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @safe_fields_required ++ @safe_fields_optional)
    |> cast_card()
    |> validate_required(@safe_fields_required)
    |> validate_card()
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> foreign_key_constraint(:quiz_id)
  end

  def cast_card(changeset) do
    case changeset.data.format do
      :multiple_choice ->
         # clear all choices
        changeset |> change(choice_1: "", choice_2: "", choice_3: "", choice_4: "")
      _ ->
        changeset
    end
  end

  def validate_card(changeset) do
    case changeset.data.format do
      :multiple_choice ->
        changeset
        # all choice fields must be filled
        |> validate_required([:choice_1, :choice_2, :choice_3, :choice_4])
        # answer must match one of the given choices (1-4)
        |> validate_format(:correct_answer, ~r/^[1234]$/)

      :number_entry ->
        # correct_answer must be a number (with or without a decimal)
        changeset |> validate_format(:correct_answer, ~r/^\d+\.?\d*$/)

      :text_entry ->
        changeset

      :true_or_false ->
        # correct_answer must be 'true' or 'false'
        changeset |> validate_format(:correct_answer, ~r/^true|false$/)
    end
  end
end
