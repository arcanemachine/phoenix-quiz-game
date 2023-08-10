defmodule QuizGame.Quizzes.Card do
  @moduledoc "The Card schema."
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    # associations
    belongs_to :quiz, QuizGame.Quizzes.Quiz

    # data
    field :image, :string
    field :question, :string
    field :answers, {:array, :string}

    # attributes
    field :format, Ecto.Enum,
      values: [:multiple_choice, :true_or_false, :text_entry, :number_entry]

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:format, :question, :image, :answers])
    |> validate_required([:format, :question, :answers])
  end
end
