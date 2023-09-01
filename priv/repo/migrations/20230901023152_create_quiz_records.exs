defmodule QuizGame.Repo.Migrations.CreateQuizRecords do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:quiz_records) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all)

      # data
      add :card_count, :integer, null: false
      add :correct_answer_count, :integer, null: false

      timestamps()
    end

    create index(:quiz_records, [:quiz_id])
    create index(:quiz_records, [:user_id])
  end
end
