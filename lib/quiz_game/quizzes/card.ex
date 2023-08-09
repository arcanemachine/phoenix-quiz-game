defmodule QuizGame.Quizzes.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :format, Ecto.Enum, values: [:multiple_choice, :true_or_false, :text_entry, :number_entry]
    field :image, :string
    field :question, :string
    field :answers, {:array, :string}
    field :quiz_id, :id

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:format, :question, :image, :answers])
    |> validate_required([:format, :question, :image, :answers])
  end
end
