defmodule QuizGame.Repo.Migrations.CreateCards do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cards) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false

      # data
      add :format, :string, default: "multiple_choice", null: false
      add :question, :string, null: false
      add :image, :string
      add :choices, {:array, :string}, null: false
      add :answer, :string, null: false

      # # attributes
      # add :shuffle_questions, :boolean, default: false, null: false
      # add :shuffle_choices, :boolean, default: false, null: false

      # # computed
      # add :index, :integer, null: false

      timestamps()
    end

    create index(:cards, [:quiz_id])
  end
end
