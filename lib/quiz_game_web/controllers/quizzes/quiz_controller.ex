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
      changeset: Quizzes.change_quiz(%Quiz{})
    )
  end

  def create(conn, %{"quiz" => quiz_params} = params) do
    # if 'generate random math questions' checkbox is not checked, then set random math question
    # count to 0 (changeset will remove any other 'random math question'-related settings)
    quiz_params =
      if Map.get(params, "checkbox-show-random-math-question-options") == "false",
        do: Map.put(quiz_params, "math_random_question_count", "0"),
        else: quiz_params

    # (unsafe) associate new quiz with current user
    unsafe_quiz_params = quiz_params |> Map.put("user_id", conn.assigns.current_user.id)

    case Quizzes.create_quiz(unsafe_quiz_params, unsafe: true) do
      {:ok, quiz} ->
        conn
        |> put_flash(:success, "Quiz created successfully")
        |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          page_title: "Create Quiz",
          changeset: changeset
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
      changeset: Quizzes.change_quiz(quiz)
    )
  end

  def update(conn, %{"quiz" => quiz_params} = params) do
    quiz = conn.assigns.quiz

    # if 'generate random math questions' checkbox is not checked, then set random math question
    # count to 0 (changeset will remove any other 'random math question'-related settings)
    quiz_params =
      if Map.get(params, "checkbox-show-random-math-question-options") == "false",
        do: Map.put(quiz_params, "math_random_question_count", "0"),
        else: quiz_params

    case Quizzes.update_quiz(quiz, quiz_params) do
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
