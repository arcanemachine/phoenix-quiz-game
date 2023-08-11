defmodule QuizGameWeb.Quizzes.QuizController do
  use QuizGameWeb, :controller

  import QuizGameWeb.Support.Router, only: [route: 2, route: 3]

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Quiz

  def index(conn, _params) do
    quizzes = Quizzes.list_quizzes()
    render(conn, :index, page_title: "Quiz List", quizzes: quizzes)
  end

  def new(conn, _params) do
    form_changeset = Quizzes.change_quiz(%Quiz{})
    render(conn, :new, page_title: "Create Quiz", changeset: form_changeset)
  end

  def create(conn, %{"quiz" => quiz_params}) do
    # set user_id to current user ID
    quiz_params = Map.put(quiz_params, "user_id", conn.assigns.current_user.id)

    case Quizzes.create_quiz(quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz created successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = form_changeset} ->
        render(conn, :new, page_title: "Create Quiz", changeset: form_changeset)
    end
  end

  def show(conn, _params) do
    quiz = conn.assigns.quiz
    render(conn, :show, page_title: "Quiz Info", quiz: quiz)
  end

  def edit(conn, _params) do
    # quiz = Quizzes.get_quiz!(quiz_id)
    quiz = conn.assigns.quiz
    changeset = Quizzes.change_quiz(quiz)
    render(conn, :edit, page_title: "Edit Quiz", quiz: quiz, changeset: changeset)
  end

  def update(conn, %{"quiz" => quiz_params}) do
    quiz = conn.assigns.quiz

    # safe_changeset = Quizzes.change_quiz(quiz, quiz_params) |> Ecto.Changeset.change()

    # prevent unsafe data from being modified by the user
    quiz_params = Map.put(quiz_params, "user_id", quiz.user_id)

    case Quizzes.update_quiz(quiz, quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz updated successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, page_title: "Edit Quiz", quiz: quiz, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    # quiz = Quizzes.get_quiz!(quiz_id)
    quiz = conn.assigns.quiz
    {:ok, _quiz} = Quizzes.delete_quiz(quiz)

    conn
    |> put_flash(:success, "Quiz deleted successfully")
    |> redirect(to: route(:quizzes, :index))
  end
end
