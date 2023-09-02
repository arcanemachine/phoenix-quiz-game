defmodule QuizGameWeb.Quizzes.RecordController do
  use QuizGameWeb, :controller
  import Ecto.Query
  alias QuizGame.Quizzes.Quiz

  def index(conn, params) do
    query =
      from q in Quiz,
        where: q.id == ^params["quiz_id"],
        preload: [:records]

    quiz = QuizGameWeb.Support.Repo.get_record_or_404(query)

    render(conn, :index,
      page_title: "Record List",
      page_subtitle: quiz.name,
      quiz: quiz
    )
  end

  # def show(conn, _params) do
  #   render(conn, :show, page_title: "Quiz Record Info", quiz: conn.assigns.quiz)
  # end
end
