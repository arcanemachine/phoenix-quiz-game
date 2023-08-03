defmodule QuizGameWeb.QuizController do
  use QuizGameWeb, :controller

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Quiz

  def index(conn, _params) do
    quizzes = Quizzes.list_quizzes()
    render(conn, :index, page_title: "Quiz List", quizzes: quizzes)
  end

  def new(conn, _params) do
    changeset = Quizzes.change_quiz(%Quiz{})
    render(conn, :new, page_title: "Create Quiz", changeset: changeset)
  end

  def create(conn, %{"quiz" => quiz_params}) do
    case Quizzes.create_quiz(quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:info, "Quiz created successfully.")
        |> redirect(to: ~p"/quizzes/#{quiz}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, page_title: "Create Quiz", changeset: changeset)
    end
  end

  def show(conn, %{"quiz_id" => quiz_id}) do
    quiz = Quizzes.get_quiz!(quiz_id)
    render(conn, :show, page_title: "Quiz Info", quiz: quiz)
  end

  def edit(conn, %{"quiz_id" => quiz_id}) do
    quiz = Quizzes.get_quiz!(quiz_id)
    changeset = Quizzes.change_quiz(quiz)
    render(conn, :edit, page_title: "Update Quiz", quiz: quiz, changeset: changeset)
  end

  def update(conn, %{"quiz_id" => quiz_id, "quiz" => quiz_params}) do
    quiz = Quizzes.get_quiz!(quiz_id)

    case Quizzes.update_quiz(quiz, quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:info, "Quiz updated successfully.")
        |> redirect(to: ~p"/quizzes/#{quiz}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, page_title: "Update Quiz", quiz: quiz, changeset: changeset)
    end
  end

  def delete(conn, %{"quiz_id" => quiz_id}) do
    quiz = Quizzes.get_quiz!(quiz_id)
    {:ok, _quiz} = Quizzes.delete_quiz(quiz)

    conn
    |> put_flash(:info, "Quiz deleted successfully.")
    |> redirect(to: ~p"/quizzes")
  end
end
