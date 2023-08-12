defmodule QuizGameWeb.Quizzes.QuizController do
  use QuizGameWeb, :controller

  import QuizGameWeb.Support.Router, only: [route: 2, route: 3]

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Quiz

  def index(conn, _params) do
    quizzes = Quizzes.list_quizzes()

    render(conn, :index,
      page_title: "Quiz List",
      quizzes: quizzes
    )
  end

  def new(conn, _params) do
    render(conn, :new,
      page_title: "Create Quiz",
      changeset: Quiz.changeset(%Quiz{})
    )
  end

  def create(conn, %{"quiz" => safe_quiz_params}) do
    # associate quiz with current user
    unsafe_quiz_params = %{"user_id" => conn.assigns.current_user.id}

    unsafe_changeset =
      Quiz.unsafe_changeset(%Quiz{}, Map.merge(safe_quiz_params, unsafe_quiz_params))

    case Quizzes.create_quiz(unsafe_changeset) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz created successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = unsafe_error_changeset} ->
        # remove unsafe data from the changeset before returning it to the template
        safe_error_changeset = Quiz.changeset_make_safe(unsafe_error_changeset)

        render(conn, :new,
          page_title: "Create Quiz",
          changeset: safe_error_changeset
        )
    end
  end

  def show(conn, _params) do
    render(conn, :show, page_title: "Quiz Info", quiz: conn.assigns.quiz)
  end

  def edit(conn, _params) do
    quiz = conn.assigns.quiz

    render(conn, :edit,
      page_title: "Edit Quiz",
      quiz: quiz,
      changeset: Quiz.changeset(quiz)
    )
  end

  def update(conn, %{"quiz" => quiz_params}) do
    quiz = conn.assigns.quiz
    changeset = Quiz.changeset(quiz, quiz_params)

    case Quizzes.update_quiz(changeset) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz updated successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = error_changeset} ->
        render(conn, :edit,
          page_title: "Edit Quiz",
          quiz: quiz,
          changeset: error_changeset
        )
    end
  end

  def delete(conn, _params) do
    {:ok, _quiz} = Quizzes.delete_quiz(conn.assigns.quiz)

    conn
    |> put_flash(:success, "Quiz deleted successfully")
    |> redirect(to: route(:quizzes, :index))
  end
end
