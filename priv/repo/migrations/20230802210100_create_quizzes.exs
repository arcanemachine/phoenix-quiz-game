defmodule QuizGame.Repo.Migrations.CreateQuizzes do
  @moduledoc false
  use Ecto.Migration

  def change do
    execute "CREATE TYPE math_random_operation AS ENUM ('add', 'subtract', 'multiply', 'divide')"

    create table(:quizzes) do
      # associations
      add :user_id, references(:users, on_delete: :restrict), null: false

      # data
      add :name, :string, null: false
      add :subject, :string, null: false

      add :math_random_question_count, :integer
      add :math_random_question_operations, {:array, :math_random_operation}
      add :math_random_question_value_min, :integer
      add :math_random_question_value_max, :integer
      add :math_random_question_left_constant, :integer

      # # attributes
      # add :is_shuffled, :boolean, default: false

      timestamps()
    end

    create index(:quizzes, [:user_id])
  end
end
