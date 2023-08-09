defmodule QuizGame.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :format, :string
      add :question, :string
      add :image, :string
      add :answers, {:array, :string}
      add :quiz_id, references(:quizzes, on_delete: :nothing)

      timestamps()
    end

    create index(:cards, [:quiz_id])
  end
end
