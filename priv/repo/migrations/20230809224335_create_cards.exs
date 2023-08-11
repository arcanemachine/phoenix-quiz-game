defmodule QuizGame.Repo.Migrations.CreateCards do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cards) do
      # associations
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false

      # data
      add :question, :string, null: false
      add :image, :string
      add :answers, {:array, :string}, null: false

      # attributes
      add :format, :string, null: false

      timestamps()
    end

    create index(:cards, [:quiz_id])
  end
end
