defmodule QuizGameWeb.Quizzes.RecordController do
  use QuizGameWeb, :controller

  import Ecto.Query

  alias QuizGame.Quizzes.{Quiz, Record}
  alias QuizGame.Repo

  def index(conn, %{"quiz_id" => quiz_id} = _params) do
    quiz = Repo.one!(from q in Quiz, where: q.id == ^quiz_id)
    records = Repo.all(from r in Record, where: r.quiz_id == ^quiz_id, preload: [:user])

    render(conn, :index,
      page_title: "Quiz Records",
      page_subtitle: quiz.name,
      quiz: quiz,
      records: records
    )
  end

  # def show(conn, _params) do
  #   render(conn, :show, page_title: "Quiz Record Info", quiz: conn.assigns.quiz)
  # end
end
