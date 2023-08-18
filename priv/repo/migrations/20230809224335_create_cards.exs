defmodule QuizGame.Repo.Migrations.CreateCards do
  @moduledoc false
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:cards) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false

      # data
      add :question, :string, null: false
      add :format, :string, null: false

      # add :image, :string

      add :choice_1, :string
      add :choice_2, :string
      add :choice_3, :string
      add :choice_4, :string

      add :correct_answer, :citext, null: false

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
