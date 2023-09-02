defmodule QuizGameWeb.Quizzes.RecordController do
  use QuizGameWeb, :controller

  import Ecto.Query

  alias QuizGame.Quizzes.{Quiz, Record}
  alias QuizGame.Repo

  def index(conn, params) do
    quiz = Repo.one!(from q in Quiz, where: q.id == ^params["quiz_id"])
    records = Repo.all(from r in Record, where: r.quiz_id == ^params["quiz_id"], preload: [:user])

    render(conn, :index,
      page_title: "Record List",
      page_subtitle: quiz.name,
      quiz: quiz,
      records: records
    )
  end

  # def show(conn, _params) do
  #   render(conn, :show, page_title: "Quiz Record Info", quiz: conn.assigns.quiz)
  # end
end
