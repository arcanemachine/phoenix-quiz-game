defmodule QuizGame.Repo.Migrations.CreateQuizzesRecords do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:records) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all)

      # data
      add :display_name, :string, null: false
      add :card_count, :integer, null: false
      add :correct_answer_count, :integer, null: false

      timestamps()
    end

    create index(:records, [:quiz_id])
    create index(:records, [:user_id])
  end
end
