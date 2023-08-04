defmodule QuizGame.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      add :name, :string
      # add :subject, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:quizzes, [:user_id])
  end
end
