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
      changeset: Quiz.changeset_safe(%Quiz{})
    )
  end

  def create(conn, %{"quiz" => quiz_params}) do
    # set user_id to current user ID
    quiz_params = Map.put(quiz_params, "user_id", conn.assigns.current_user.id)

    # create changeset with non-user-modifiable data
    unsafe_changeset = Quiz.changeset_unsafe(%Quiz{}, quiz_params)

    case Quizzes.create_quiz2(unsafe_changeset) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz created successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = error_changeset} ->
        render(conn, :new,
          page_title: "Create Quiz",
          changeset: error_changeset
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
      changeset: Quiz.changeset_safe(quiz)
    )
  end

  def update(conn, %{"quiz" => quiz_params}) do
    quiz = conn.assigns.quiz

    # use safe changeset to prevent unsafe data from being modified by the user
    safe_changeset = Quiz.changeset_safe(quiz, quiz_params)

    case Quizzes.update_quiz2(safe_changeset) do
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
    # quiz = Quizzes.get_quiz!(quiz_id)
    quiz = conn.assigns.quiz
    {:ok, _quiz} = Quizzes.delete_quiz(quiz)

    conn
    |> put_flash(:success, "Quiz deleted successfully")
    |> redirect(to: route(:quizzes, :index))
  end
end
