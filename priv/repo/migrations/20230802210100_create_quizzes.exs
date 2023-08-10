defmodule QuizGame.Repo.Migrations.CreateQuizzes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      # associations
      add :user_id, references(:users, on_delete: :restrict)

      # data
      add :name, :string

      timestamps()
    end

    create index(:quizzes, [:user_id])
  end
end
