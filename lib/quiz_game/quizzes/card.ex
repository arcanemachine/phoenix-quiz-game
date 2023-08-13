defmodule QuizGame.Quizzes.Card do
  @moduledoc "The Card schema."
  use Ecto.Schema
  import Ecto.Changeset

  @doc "Creates :format options usable in a <.input type='select'> component."
  def format_options() do
    Ecto.Enum.values(__MODULE__, :format) |> Enum.map(fn item ->
      {item |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize(), item}
    end)
  end

  schema "cards" do
    # associations
    belongs_to :quiz, QuizGame.Quizzes.Quiz

    # data
    field :format, Ecto.Enum,
      values: [:multiple_choice, :true_or_false, :text_entry, :number_entry]
    field :image, :string
    field :question, :string
    field :answers, {:array, :string}

    # # computed
    # field :index, :integer

    timestamps()
  end

  @unsafe_fields_required [:quiz_id]
  @safe_fields_required [:format, :question, :answers]
  @safe_fields_optional [:image]

  @doc "A changeset whose fields can be safely modified by the user."
  def changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@safe_fields_required)
  end

  @doc "A changeset that contains one or more fields that should not be modified by the user."
  def unsafe_changeset(card \\ %__MODULE__{}, attrs \\ %{})

  def unsafe_changeset(%__MODULE__{} = card, attrs) do
    card
    |> cast(attrs, @unsafe_fields_required ++ @safe_fields_required ++ @safe_fields_optional)
    |> validate_required(@unsafe_fields_required ++ @safe_fields_required)
    |> foreign_key_constraint(:quiz_id)
  end

  # @doc "Returns a changeset with all unsafe parameters removed."
  # def changeset_make_safe(%Ecto.Changeset{} = unsafe_changeset) do
  #   changeset(%__MODULE__{}, unsafe_changeset.params)
  # end
end
