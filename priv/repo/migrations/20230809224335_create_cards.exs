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
      add :answers, {:array, :string}, null: false
      add :correct_answer, :integer, default: 0, null: false

      # # attributes
      # add :shuffle_questions, :boolean, default: false, null: false
      # add :shuffle_answers, :boolean, default: false, null: false

      # # computed
      # add :index, :integer, null: false

      timestamps()
    end

    create index(:cards, [:quiz_id])
  end
end
