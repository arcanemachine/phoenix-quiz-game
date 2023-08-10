defmodule QuizGame.Repo.Migrations.CreateCards do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cards) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all)

      # data
      add :question, :string
      add :image, :string
      add :answers, {:array, :string}

      # attributes
      add :format, :string

      timestamps()
    end

    create index(:cards, [:quiz_id])
  end
end
