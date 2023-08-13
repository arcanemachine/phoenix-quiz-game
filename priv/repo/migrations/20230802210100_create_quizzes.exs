defmodule QuizGame.Repo.Migrations.CreateQuizzes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      # associations
      add :user_id, references(:users, on_delete: :restrict), null: false

      # data
      add :name, :string, null: false
      # add :format, :string, null: false

      # # attributes
      # add :is_shuffled, :boolean, default: false

      timestamps()
    end

    create index(:quizzes, [:user_id])
  end
end
